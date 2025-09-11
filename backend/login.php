<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

// CORS is already handled in db.php; keep this file lean.

/** ---- 1) Read input: support JSON and x-www-form-urlencoded ---- */
$raw = file_get_contents("php://input");
$payload = json_decode($raw, true) ?: [];

$input    = $_POST['email']    ?? $_POST['username'] ?? $payload['email']    ?? $payload['username'] ?? '';
$password = $_POST['password'] ?? $payload['password'] ?? '';
$role     = $payload['role']     ?? ''; // <-- Read role from request


if ($input === '' || $password === '') {
  echo json_encode(['success' => false, 'message' => 'Email/Username and password required']);
  exit;
}

/** ---- 2) Find user by email OR username ---- */
$stmt = $conn->prepare("SELECT * FROM users WHERE (email = ? OR username = ?)");
$stmt->bind_param("ss", $input, $input);
$stmt->execute();
$result = $stmt->get_result();

if (!($user = $result->fetch_assoc())) {
  echo json_encode(['success' => false, 'message' => 'Account not found']);
  exit;
}

/** ---- 3) Verify password (hashed or plain fallback) ---- */
$ok = password_verify($password, $user['password']) || hash_equals($user['password'], $password);
if (!$ok) {
  echo json_encode(['success' => false, 'message' => 'Incorrect password']);
  exit;
}

/** ---- 4) Check if the account is approved by admin ---- */
if ($user['first_login'] == 1 && $user['is_approved'] != 1) {
    echo json_encode(['success' => false, 'message' => 'Account not approved by admin.']);
    exit;
}

/** ---- 5) Generate and store 4-digit login code ---- */
$login_code = str_pad((string)random_int(0, 9999), 4, '0', STR_PAD_LEFT);
$upd = $conn->prepare("UPDATE users SET login_code = ? WHERE id = ?");
$upd->bind_param("si", $login_code, $user['id']);
$upd->execute();

/** ---- 6) Send email via Resend API ---- */
$api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';
$email_data = [
    "from" => "no-reply@mail.stockmgmt.app",
    "to" => $user['email'],
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

$mailStatus = ($http_code === 200 || $http_code === 202) ? 'sent' : $response;

/** ---- 7) Optional: return code in response for debugging only ---- */
$debugIncludeCode = (bool)(getenv('DEBUG_RETURN_CODE') ?: false);

echo json_encode([
  'success'      => true,
  'require_2fa'  => true,
  'email'        => $user['email'],
  'message'      => 'Login code sent to your email.',
  'mail_status'  => $mailStatus,
  'code_debug'   => $debugIncludeCode ? $login_code : null
]);

// After successful login:
if ($user['first_login'] == 1) {
    $stmt = $conn->prepare("UPDATE users SET first_login = 0 WHERE id = ?");
    $stmt->bind_param("i", $user['id']);
    $stmt->execute();
}
