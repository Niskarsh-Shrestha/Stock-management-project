<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['supplierName'];
    $categoryID = $_POST['categoryID'];
    $contact = $_POST['contact'];
    $email = $_POST['email'];
    $lastOrderDate = $_POST['lastOrderDate'];

    $stmt = $conn->prepare("INSERT INTO suppliers (supplierName, categoryID, contact, email, lastOrderDate, dateAdded)
                            VALUES (?, ?, ?, ?, ?, NOW())");
    $stmt->bind_param("sisss", $name, $categoryID, $contact, $email, $lastOrderDate);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $stmt->error]);
    }
}

