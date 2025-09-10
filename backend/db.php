<?php
// ===== CORS (must reflect your site; NOT "*") =====
$allowedOrigin = getenv('CORS_ALLOW_ORIGIN') ?: 'https://stock-management-project.vercel.app';
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if ($origin && stripos($origin, parse_url($allowedOrigin, PHP_URL_HOST)) !== false) {
  header("Access-Control-Allow-Origin: $origin");
} else {
  header("Access-Control-Allow-Origin: $allowedOrigin");
}
header("Vary: Origin");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Credentials: true");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

header('Content-Type: application/json');

// ===== Session cookie flags for cross-site =====
if (PHP_VERSION_ID >= 70300) {
  session_set_cookie_params([
    'lifetime' => 0,
    'path'     => '/',
    'domain'   => '',
    'secure'   => true,
    'httponly' => true,
    'samesite' => 'None',
  ]);
} else {
  ini_set('session.cookie_secure', '1');
  ini_set('session.cookie_httponly', '1');
  ini_set('session.cookie_samesite', 'None');
}
if (!ini_get('session.save_path')) {
  @session_save_path(sys_get_temp_dir());
}

// ===== DB connect (your current defaults preserved) =====
$host = getenv('DB_HOST') ?: 'metro.proxy.rlwy.net';
$port = (int)(getenv('DB_PORT') ?: 41275);
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: 'MleCpOFlqfNlXYmBRGbktfaMkmwCsCjY';
$name = getenv('DB_NAME') ?: 'railway';

$conn = new mysqli($host, $user, $pass, $name, $port);
if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["success" => false, "message" => "Database connection failed"]);
  exit;
}
$conn->set_charset('utf8mb4');
?>
