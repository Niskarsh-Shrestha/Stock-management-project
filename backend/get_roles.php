<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\get_roles.php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
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