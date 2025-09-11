<?php
header("Access-Control-Allow-Origin: https://stock-management-project.vercel.app");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

$raw = file_get_contents("php://input");
$payload = json_decode($raw, true) ?: [];
$email    = $_POST['email']    ?? $payload['email']    ?? null;
$username = $_POST['username'] ?? $payload['username'] ?? null;

if (!$email && !$username) {
    echo json_encode(['success' => false, 'message' => 'Email or username required']);
    exit;
}

$col = $email ? 'email' : 'username';
$val = $email ?: $username;

$stmt = $conn->prepare("SELECT id, email, is_verified FROM users WHERE {$col} = ?");
$stmt->bind_param("s", $val);
$stmt->execute();
$res = $stmt->get_result();
if (!($row = $res->fetch_assoc())) {
    echo json_encode(['success' => false, 'message' => 'Account not found']);
    exit;
}
if ((int)$row['is_verified'] !== 1) {
    echo json_encode(['success' => false, 'message' => 'Account not approved by admin.']);
    exit;
}

$login_code = str_pad((string)random_int(0, 9999), 4, '0', STR_PAD_LEFT);
$upd = $conn->prepare("UPDATE users SET login_code = ? WHERE id = ?");
$upd->bind_param("si", $login_code, $row['id']);
$upd->execute();

// Send login code email using Resend API
$api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';

$email_data = [
    "from" => "niskarshshrestha@gmail.com",
    "to" => $row['email'],
    "subject" => "Your Admin Login Code",
    "html" => "<p>Your 4-digit login code is: <b>{$login_code}</b></p>"
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

echo json_encode(['success' => true, 'message' => 'Code resent']);
?>