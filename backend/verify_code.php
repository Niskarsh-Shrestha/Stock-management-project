<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

// Input: email OR username + code
$raw = file_get_contents("php://input");
$payload = json_decode($raw, true) ?: [];
$email    = $_POST['email']    ?? $payload['email']    ?? null;
$username = $_POST['username'] ?? $payload['username'] ?? null;
$code     = $_POST['code']     ?? $payload['code']     ?? '';

if ((!$email && !$username) || $code === '') {
  echo json_encode(['success' => false, 'message' => 'Email/Username and code required']);
  exit;
}

$col = $email ? 'email' : 'username';
$val = $email ?: $username;

$stmt = $conn->prepare("SELECT id, login_code, is_verified, role, username, email FROM users WHERE {$col} = ?");
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

// Compare code
if (!hash_equals((string)$row['login_code'], (string)$code)) {
  echo json_encode(['success' => false, 'message' => 'Invalid code']);
  exit;
}

// OPTIONAL: clear code after success
$upd = $conn->prepare("UPDATE users SET login_code = NULL WHERE id = ?");
$upd->bind_param("i", $row['id']);
$upd->execute();

// Minimal session token (opaque). For production, consider JWT.
$token = bin2hex(random_bytes(24));

echo json_encode([
  'success' => true,
  'message' => '2FA verified',
  'token'   => $token,
  'user'    => [
    'id'       => (int)$row['id'],
    'username' => $row['username'],
    'email'    => $row['email'],
    'role'     => $row['role'] ?? 'user'
  ]
]);
?>