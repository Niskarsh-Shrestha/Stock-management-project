<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\get_roles.php
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed_origins = [
    'https://stock-management-project.vercel.app',
    'http://localhost:63166' // <-- Your current local Flutter port
];
if (in_array($origin, $allowed_origins, true)) {
    header("Access-Control-Allow-Origin: $origin");
}
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

header("Content-Type: application/json");
include 'db.php';

$result = $conn->query("SELECT id, role_name FROM roles");
$roles = [];
while ($row = $result->fetch_assoc()) {
    $roles[] = $row;
}
echo json_encode(["roles" => $roles]);
?>