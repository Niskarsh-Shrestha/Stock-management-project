<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));
$email = trim($data->email ?? '');
$new_password = $data->new_password ?? '';

if (empty($email) || empty($new_password)) {
    echo json_encode(["success" => false, "message" => "Email and new password are required."]);
    exit;
}

$hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

$sql = "UPDATE users SET password = ?, reset_code = NULL WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $hashed_password, $email);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Password has been reset."]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to reset password."]);
}
?>