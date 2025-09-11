<?php
// filepath: c:\xampp\htdocs\stock_management_project\backend\add_user.php
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

$data = json_decode(file_get_contents("php://input"));
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$password = $data->password ?? '';
$role = trim($data->role ?? '');
$is_approved = 0; // Add is_approved variable

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

// Add is_approved to your INSERT statement
$sql = "INSERT INTO users (username, password, email, is_approved, ...) VALUES ('$username', '$hashedPassword', '$email', $is_approved, ...)";
$stmt = $conn->prepare($sql);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "User added successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to add user."]);
}
?>