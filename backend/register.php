<?php
header("Access-Control-Allow-Origin: https://stock-management-project.vercel.app");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header("Content-Type: application/json");

// Always include DB first!
require 'db.php';

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

// Generate a 4-digit verification code
$registration_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
$is_verified = 0;
$is_verified_email = 0;
$is_approved = ($userCount == 0 && strtolower($role) == 'admin') ? 1 : 0;

// Insert user into database
$stmt = $conn->prepare("INSERT INTO users (username, email, password, role, is_verified, is_verified_email, is_approved, registration_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssssss", $username, $email, $hashedPassword, $role, $is_verified, $is_verified_email, $is_approved, $registration_code);

if ($stmt->execute()) {
    // Send registration code email using Resend API
    $api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';
    $email_data = [
        "from" => "no-reply@mail.stockmgmt.app",
        "to" => $email,
        "subject" => "Your Registration Verification Code",
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

    $mailStatus = ($http_code === 200 || $http_code === 202) ? 'sent' : $response;

    echo json_encode([
        'success' => true,
        'message' => 'Registration successful. Verification code sent to your email.',
        'mail_status' => $mailStatus
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Registration failed.']);
}
?>
