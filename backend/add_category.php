<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db.php';

$name = $_POST['categoryName'];

$query = "INSERT INTO categories (CategoryName, dateAdded) VALUES (?, NOW())";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $name);

if ($stmt->execute()) {
    echo "Category added successfully";
} else {
    echo "Failed to add category";
}

