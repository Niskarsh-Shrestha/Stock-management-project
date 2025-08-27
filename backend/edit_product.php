<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $conn->prepare("UPDATE products SET productName=?, quantity=?, availability=?, category=?, warehouseLocation=?, supplierName=?, lastUpdated=NOW(), modifiedBy=? WHERE id=?");
    $stmt->bind_param(
        "sisssssi",
        $_POST['productName'],
        $_POST['quantity'],
        $_POST['availability'],
        $_POST['category'],
        $_POST['warehouseLocation'],
        $_POST['supplierName'],
        $_POST['modifiedBy'],
        $_POST['id']   // <--- **Important: uses 'id' as key here**
    );
    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => $stmt->error]);
    }
    $stmt->close();
}
?>
