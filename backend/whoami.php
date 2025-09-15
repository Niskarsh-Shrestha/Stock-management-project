<?php
require_once __DIR__ . '/auth_check.php';
include 'cors.php';
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

echo json_encode([
  'success'   => true,
  'user_id'   => $user_id,
  'user_role' => $user_role,
  'sid'       => session_id(),
]);