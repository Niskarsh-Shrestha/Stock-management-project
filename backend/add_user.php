<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\add_user.php
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

$data = json_decode(file_get_contents("php://input"));
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$password = $data->password ?? '';
$role = trim($data->role ?? '');

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

if (empty($username) || empty($email) || empty($password) || empty($role)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

// Check if email already exists
$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email already exists."]);
    exit;
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("INSERT INTO users (username, email, role, password, is_verified) VALUES (?, ?, ?, ?, 1)");
$stmt->bind_param("ssss", $username, $email, $role, $hashedPassword);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "User added successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to add user."]);
}
?>