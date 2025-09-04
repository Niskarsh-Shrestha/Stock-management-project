<?php
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));
$id = intval($data->id ?? 0);
$role_name = trim($data->role_name ?? '');

if ($id && $role_name) {
    $stmt = $conn->prepare("UPDATE roles SET role_name=? WHERE id=?");
    $stmt->bind_param("si", $role_name, $id);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Role updated."]);
    } else {
        echo json_encode(["success" => false, "message" => "Update failed."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid data."]);
}
?>