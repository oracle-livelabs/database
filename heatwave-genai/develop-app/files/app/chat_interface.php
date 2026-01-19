<?php
session_start();

require_once 'HeatWaveRAG.php'; // Assuming your RAG class is in this file

// Initialize chat history if it doesn't exist
if (!isset($_SESSION['chat_history'])) {
    $_SESSION['chat_history'] = [];
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['user_query'])) {
    $userQuery = $_POST['user_query'];
    
    try {
        $rag = new HeatWaveRAG('your_mysql_host', 'your_username', 'your_password', 'genai_db');
        $rag->loadModel(); // Call this once at the start of your application
        $response = $rag->runRAG($userQuery);
        $rag->close();

        // Add to chat history
        $_SESSION['chat_history'][] = [
            'query' => $userQuery,
            'response' => $response['text'],
            'citations' => $response['citations'] ?? []
        ];
    } catch (Exception $e) {
        $error = "An error occurred: " . $e->getMessage();
    }
}

// Clear chat history if requested
if (isset($_POST['clear_history'])) {
    $_SESSION['chat_history'] = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HeatWave RAG Chat</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        .chat-history {
            margin-bottom: 20px;
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 10px;
            background-color: #fff;
        }
        .user-query {
            background-color: #e6f2ff;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .ai-response {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .citations {
            font-size: 0.9em;
            color: #666;
            margin-top: 5px;
        }
        form {
            display: flex;
            margin-top: 20px;
        }
        input[type="text"] {
            flex-grow: 1;
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        input[type="submit"] {
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 10px;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .clear-history {
            text-align: right;
            margin-top: 10px;
        }
        .clear-history input[type="submit"] {
            background-color: #f44336;
        }
        .clear-history input[type="submit"]:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>HeatWave RAG Chat</h1>
        
        <?php if (isset($error)): ?>
            <p style="color: red;"><?php echo $error; ?></p>
        <?php endif; ?>

        <div class="chat-history">
            <?php foreach ($_SESSION['chat_history'] as $chat): ?>
                <div class="user-query">
                    <strong>You:</strong> <?php echo htmlspecialchars($chat['query']); ?>
                </div>
                <div class="ai-response">
                    <strong>AI:</strong> <?php echo nl2br(htmlspecialchars($chat['response'])); ?>
                    <?php if (!empty($chat['citations'])): ?>
                        <div class="citations">
                            <strong>Citations:</strong>
                            <ul>
                                <?php foreach ($chat['citations'] as $citation): ?>
                                    <li><?php echo htmlspecialchars($citation['segment']); ?> (Document: <?php echo htmlspecialchars($citation['document_name']); ?>)</li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                    <?php endif; ?>
                </div>
            <?php endforeach; ?>
        </div>

        <form method="post" action="">
            <input type="text" name="user_query" placeholder="Ask a question..." required>
            <input type="submit" value="Send">
        </form>

        <div class="clear-history">
            <form method="post" action="">
                <input type="submit" name="clear_history" value="Clear Chat History">
            </form>
        </div>
    </div>
</body>
</html>
