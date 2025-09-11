<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));
$email = trim($data->email ?? '');

if (empty($email)) {
    echo json_encode(["success" => false, "message" => "Email is required."]);
    exit;
}

// Check if user exists
$sql = "SELECT * FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $code = rand(1000, 9999);
    // Store code in DB
    $update = $conn->prepare("UPDATE users SET reset_code = ? WHERE email = ?");
    $update->bind_param("ss", $code, $email);
    $update->execute();

    // Send code to email using Resend API
    $api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';
    $email_data = [
        "from" => "no-reply@mail.stockmgmt.app",
        "to" => $email,
        "subject" => "Your Password Reset Code",
        "html" => "Your password reset code is: <b>$code</b>"
    ];

    $ch = curl_init("https://api.resend.com/emails");
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $api_key",
        "Content-Type: application/json"
    ]);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($email_data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code === 200 || $http_code === 202) {
        echo json_encode(["success" => true, "message" => "A 4-digit code has been sent to your email."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to send email. Mail error: $response"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Email not found."]);
}
?>