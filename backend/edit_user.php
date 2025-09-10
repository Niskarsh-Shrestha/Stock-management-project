<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));
$id = intval($data->id ?? 0);
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$role = trim($data->role ?? '');

if ($id && $username && $email && $role) {
    $stmt = $conn->prepare("UPDATE users SET username=?, email=?, role=? WHERE id=?");
    $stmt->bind_param("sssi", $username, $email, $role, $id);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "User updated."]);
    } else {
        echo json_encode(["success" => false, "message" => "Update failed."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid data."]);
}
?>