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

if ($id) {
    $stmt = $conn->prepare("DELETE FROM roles WHERE id=?");
    $stmt->bind_param("i", $id);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Role deleted."]);
    } else {
        echo json_encode(["success" => false, "message" => "Delete failed."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid role ID."]);
}
?>