<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\add_role.php
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

$data = json_decode(file_get_contents("php://input"));
$role = trim($data->role ?? '');

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

if (empty($role)) {
    echo json_encode(["success" => false, "message" => "Role name is required."]);
    exit;
}

// Check if role already exists
$check = $conn->prepare("SELECT id FROM roles WHERE role_name = ?");
$check->bind_param("s", $role);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Role already exists."]);
    exit;
}

// Insert new role
$stmt = $conn->prepare("INSERT INTO roles (role_name) VALUES (?)");
$stmt->bind_param("s", $role);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Role added successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to add role."]);
}
?>