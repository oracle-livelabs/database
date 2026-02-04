<?php

class HeatWaveRAG {
    private $conn;
    private $vectorStore = 'genai_db.livelab_embedding_pdf';

    public function __construct($host, $user, $password, $database) {
        $this->conn = new mysqli($host, $user, $password, $database);
        if ($this->conn->connect_error) {
            die("Connection failed: " . $this->conn->connect_error);
        }
    }

    public function loadModel() {
    	if (!$this->modelLoaded) {
        	$query = "CALL sys.ML_MODEL_LOAD('mistral-7b-instruct-v3', NULL)";
        	$result = $this->conn->query($query);
        	if ($result === false) {
            		throw new Exception("Failed to load model: " . $this->conn->error);
        	}
        	$this->modelLoaded = true;
    	}
    }

    public function runRAG($userQuery) {
        // Set the options
        $optionsQuery = "SET @options = JSON_OBJECT('vector_store', JSON_ARRAY('{$this->vectorStore}'))";
        $this->conn->query($optionsQuery);
        
        // Set the query
        $escapedQuery = $this->conn->real_escape_string($userQuery);
        $querySetQuery = "SET @query = '$escapedQuery'";
        $this->conn->query($querySetQuery);
        
        // Run the RAG procedure
        $ragQuery = "CALL sys.ML_RAG(@query, @output, @options)";
        $this->conn->query($ragQuery);
        
        // Fetch the result
        $resultQuery = "SELECT JSON_PRETTY(@output) AS result";
        $result = $this->conn->query($resultQuery);
        
        if ($result === false) {
            throw new Exception("Query failed: " . $this->conn->error);
        }
        
        $row = $result->fetch_assoc();
        return json_decode($row['result'], true);
    }

    public function close() {
        $this->conn->close();
    }
}

