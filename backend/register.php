<?php
header("Access-Control-Allow-Origin: https://stock-management-project.vercel.app");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header("Content-Type: application/json");

// Read JSON payload
$data = json_decode(file_get_contents('php://input'), true);

$username = $data['username'] ?? '';
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';
$role = $data['role'] ?? '';

// Validate fields
if (!$username || !$email || !$password || !$role) {
    echo json_encode(['success' => false, 'message' => 'All fields required']);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Always generate a registration code
$registration_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
$is_verified = 0;
$is_approved = 0;

// Check if there are any users
$userCount = $conn->query("SELECT COUNT(*) as cnt FROM users")->fetch_assoc()['cnt'];

// Check if there is at least one admin
$adminCount = $conn->query("SELECT COUNT(*) as cnt FROM users WHERE role = 'admin'")->fetch_assoc()['cnt'];

// If no users, only allow admin registration
if ($userCount == 0 && strtolower($role) != 'admin') {
    echo json_encode(['success' => false, 'message' => 'First user must be an admin.']);
    exit;
}

// If no admin, block manager/employee registration
if ($adminCount == 0 && strtolower($role) != 'admin') {
    echo json_encode(['success' => false, 'message' => 'At least one admin must exist before creating manager or employee accounts.']);
    exit;
}

// First admin does not need approval
$is_approved = ($userCount == 0 && strtolower($role) == 'admin') ? 1 : 0;

// Send registration code email using Resend API
$api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2'; // Your Resend API key

$email_data = [
    "from" => "no-reply@mail.stockmgmt.app", // Use your verified sender from Resend
    "to" => $email,
    "subject" => "Your Registration Code",
    "html" => "<p>Your verification code is: <b>$registration_code</b></p>"
];

$ch = curl_init("https://api.resend.com/emails");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer $api_key",
    "Content-Type: application/json"
]);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($email_data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($http_code !== 200 && $http_code !== 202) {
    echo json_encode(['success' => false, 'message' => 'Mail error: ' . $response]);
    exit;
}

// Insert user into database
require 'db.php';
$stmt = $conn->prepare("INSERT INTO users (username, email, password, role, is_verified, registration_code, is_approved) VALUES (?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssisi", $username, $email, $hashedPassword, $role, $is_verified, $registration_code, $is_approved);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Registration successful. Please check your email for the verification code.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Registration failed.']);
}
?>
