<?php
require_once __DIR__ . '/db.php'; // Include database connection
header("Access-Control-Allow-Origin: *"); header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Check for session ID in custom header (for API clients)
$hdrSid = $_SERVER['HTTP_X_SESSION_ID'] ?? null;
if ($hdrSid) {
  // If a session is already active, close it before switching session ID
  if (session_status() === PHP_SESSION_ACTIVE) { session_write_close(); }
  session_id($hdrSid); // Set session ID from header
}

// Start session if not already active
if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }

// If user is not logged in or role is missing, block access
if (empty($_SESSION['user_id']) || empty($_SESSION['user_role'])) {
  echo json_encode(['success' => false, 'message' => 'Unauthorized']);
  exit;
}

// Set user ID and role for use in the endpoint
$user_id   = (int)$_SESSION['user_id'];
$user_role = strtolower((string)$_SESSION['user_role']);