<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
// Show errors for debugging (comment out in production)
ini_set('display_errors', 1);
error_reporting(E_ALL);

include 'db.php';

$sql = "SELECT * FROM suppliers ORDER BY supplierID DESC";
$result = $conn->query($sql);

$suppliers = [];

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $suppliers[] = $row;
    }
    echo json_encode(["suppliers" => $suppliers]);
} else {
    // Return an error JSON if query failed
    http_response_code(500);
    echo json_encode(["error" => "Failed to fetch suppliers"]);
}

