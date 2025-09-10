<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

$data = json_decode(file_get_contents("php://input"));
$email = trim($data->email ?? '');
$code = trim($data->code ?? '');

if (empty($email) || empty($code)) {
    echo json_encode(["success" => false, "message" => "Email and code are required."]);
    exit;
}

$sql = "SELECT login_code FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();
    if ($row['login_code'] === $code) {
        // Clear code after successful verification
        $clear = $conn->prepare("UPDATE users SET login_code = NULL WHERE email = ?");
        $clear->bind_param("s", $email);
        $clear->execute();

        // Fetch user info
        $userInfo = $conn->prepare("SELECT id, username, email, role FROM users WHERE email = ?");
        $userInfo->bind_param("s", $email);
        $userInfo->execute();
        $userResult = $userInfo->get_result();
        $user = $userResult->fetch_assoc();

        session_regenerate_id(true);
        $_SESSION['user_id']   = (int)$user['id'];
        $_SESSION['user_role'] = strtolower($user['role']);

        echo json_encode([
          "success"  => true,
          "message"  => "Login successful.",
          "username" => $user['username'],
          "email"    => $user['email'],
          "role"     => $_SESSION['user_role'],
          "sid"      => session_id()
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Incorrect code."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Email not found."]);
}
?>