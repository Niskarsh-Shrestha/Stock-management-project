<?php
// CORS setup
header("Access-Control-Allow-Origin: " . (getenv('CORS_ALLOW_ORIGIN') ?: '*'));
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

// Default values for local dev (public host/port)
$defaultHost = 'metro.proxy.rlwy.net';
$defaultPort = 41275;
$defaultUser = 'root';
$defaultPass = 'MleCpOFlqfNlXYmBRGbktfaMkmwCsCjY';
$defaultDB   = 'railway';

// Use environment variables if set (Railway internal)
$host = getenv('DB_HOST') ?: $defaultHost;
$port = getenv('DB_PORT') ?: $defaultPort;
$user = getenv('DB_USER') ?: $defaultUser;
$pass = getenv('DB_PASS') ?: $defaultPass;
$name = getenv('DB_NAME') ?: $defaultDB;

// Connect
$conn = new mysqli($host, $user, $pass, $name, $port);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit;
}

$conn->set_charset('utf8mb4');
?>
