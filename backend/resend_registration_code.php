<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/mailer.php';

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

$registration_code = str_pad((string)random_int(0, 9999), 4, '0', STR_PAD_LEFT);
$upd = $conn->prepare("UPDATE users SET registration_code = ? WHERE id = ?");
$upd->bind_param("si", $registration_code, $row['id']);
$upd->execute();

$subject = 'Your Registration Code';
$html    = "<p>Your 4-digit registration code is: <b>{$registration_code}</b></p>";
$status  = send_email_api($row['email'], $subject, $html);

echo json_encode(['success' => true, 'message' => 'Code resent', 'mail_status' => $status]);
?>