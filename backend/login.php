<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

// CORS is already handled in db.php; keep this file lean.

/** ---- 1) Read input: support JSON and x-www-form-urlencoded ---- */
$raw = file_get_contents("php://input");
$payload = json_decode($raw, true) ?: [];

$input    = $_POST['email']    ?? $_POST['username'] ?? $payload['email']    ?? $payload['username'] ?? '';
$password = $_POST['password'] ?? $payload['password'] ?? '';

if ($input === '' || $password === '') {
  echo json_encode(['success' => false, 'message' => 'Email/Username and password required']);
  exit;
}

/** ---- 2) Find user by email OR username ---- */
$stmt = $conn->prepare("SELECT * FROM users WHERE (email = ? OR username = ?)");
$stmt->bind_param("ss", $input, $input);
$stmt->execute();
$result = $stmt->get_result();

if (!($row = $result->fetch_assoc())) {
  echo json_encode(['success' => false, 'message' => 'Account not found']);
  exit;
}

if ((int)$row['is_verified'] !== 1) {
  echo json_encode(['success' => false, 'message' => 'Account not approved by admin.']);
  exit;
}

/** ---- 3) Verify password (hashed or plain fallback) ---- */
$ok = password_verify($password, $row['password']) || hash_equals($row['password'], $password);
if (!$ok) {
  echo json_encode(['success' => false, 'message' => 'Incorrect password']);
  exit;
}

/** ---- 4) Generate and store 4-digit login code ---- */
$login_code = str_pad((string)random_int(0, 9999), 4, '0', STR_PAD_LEFT);
$upd = $conn->prepare("UPDATE users SET login_code = ? WHERE id = ?");
$upd->bind_param("si", $login_code, $row['id']);
$upd->execute();

/** ---- 5) Send email via SMTP (env-driven) ---- */
require_once __DIR__ . '/mailer.php';
$subject = 'Your Admin Login Code';
$html    = "<p>Your 4-digit login code is: <b>{$login_code}</b></p>";

$mailStatus = send_email_api($row['email'], $subject, $html);

/** ---- 6) Optional: return code in response for debugging only ---- */
$debugIncludeCode = (bool)(getenv('DEBUG_RETURN_CODE') ?: false);

echo json_encode([
  'success'      => true,
  'require_2fa'  => true,
  'email'        => $row['email'],
  'message'      => 'Login code sent to your email.',
  'mail_status'  => $mailStatus,
  'code_debug'   => $debugIncludeCode ? $login_code : null
]);
