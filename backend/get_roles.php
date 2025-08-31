<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\get_roles.php
header("Content-Type: application/json");
include 'db.php';

$result = $conn->query("SELECT id, role_name FROM roles");
$roles = [];
while ($row = $result->fetch_assoc()) {
    $roles[] = $row;
}
echo json_encode(["roles" => $roles]);
?>