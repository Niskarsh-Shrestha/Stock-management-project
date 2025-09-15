<?php
include 'cors.php';
// Allow CORS for frontend app
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

// Read input data (JSON or form)
$raw = file_get_contents("php://input");
$payload = json_decode($raw, true) ?: [];
$email    = $_POST['email']    ?? $payload['email']    ?? null;
$username = $_POST['username'] ?? $payload['username'] ?? null;

// Require either email or username
if (!$email && !$username) {
    echo json_encode(['success' => false, 'message' => 'Email or username required']);
    exit;
}

// Determine which column to use for lookup
$col = $email ? 'email' : 'username';
$val = $email ?: $username;

// Find user by email or username
$stmt = $conn->prepare("SELECT id, email, is_verified FROM users WHERE {$col} = ?");
$stmt->bind_param("s", $val);
$stmt->execute();
$res = $stmt->get_result();
if (!($row = $res->fetch_assoc())) {
    echo json_encode(['success' => false, 'message' => 'Account not found']);
    exit;
}

// Check if account is verified (approved)
if ((int)$row['is_verified'] !== 1) {
    echo json_encode(['success' => false, 'message' => 'verified account required']);
    exit;
}

// Generate new 4-digit login code and update user
$login_code = str_pad((string)random_int(0, 9999), 4, '0', STR_PAD_LEFT);
$upd = $conn->prepare("UPDATE users SET login_code = ? WHERE id = ?");
$upd->bind_param("si", $login_code, $row['id']);
$upd->execute();

// Prepare email data for Resend API
$api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';
$email_data = [
    "from" => "no-reply@mail.stockmgmt.app",
    "to" => $row['email'],
    "subject" => "Your Admin Login Code",
    "html" => "<p>Your 4-digit login code is: <b>{$login_code}</b></p>"
];

// Send email using Resend API
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

// Handle mail errors
if ($http_code !== 200 && $http_code !== 202) {
    echo json_encode(['success' => false, 'message' => 'Mail error: ' . $response]);
    exit;
}

// Success response
echo json_encode(['success' => true, 'message' => 'Code resent']);
?>