<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));

$login_id = trim($data->login_id ?? '');
$role = trim($data->role ?? '');
$password = $data->password ?? '';

// Validate input
if (empty($login_id) || empty($role) || empty($password)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

// Check if user exists by email or username
$sql = "SELECT * FROM users WHERE (email = ? OR username = ?) AND role = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $login_id, $login_id, $role);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    
    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "success" => true,
            "message" => "Login successful.",
            "role" => $user['role'],
            "username" => $user['username'],
            "email" => $user['email']
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Incorrect password."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User not found."]);
}
?>
