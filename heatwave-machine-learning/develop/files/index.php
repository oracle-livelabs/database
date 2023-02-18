<?php
  require_once "config.php";

  // Check connection
  if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
  }


  $petal_lErr = $petal_wErr = $sepal_lErr = $sepal_wErr = "";
  $iris_model = $row_input = $predict = "";
  $sepal_l =  $sepal_w =  $petal_l = $petal_w ="";

  if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if (empty($_POST["sepal_l"])) {
      $sepal_lErr = "Sepal Length is required";
    } else {
      $sepal_l = test_input($_POST["sepal_l"]);
    }
    if (empty($_POST["sepal_w"])) {
      $sepal_wErr = "Sepal Width is required";
    } else {
      $sepal_w = test_input($_POST["sepal_w"]);
    }
      if (empty($_POST["petal_l"])) {
      $petal_lErr = "Petal Length is required";
    } else {
      $petal_l = test_input($_POST["petal_l"]);
    }
    if (empty($_POST["petal_w"])) {
      $petal_wErr = "Petal Width is required";
    } else {
      $petal_w = test_input($_POST["petal_w"]);
    }
  }

  function test_input($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
  }

  function load_model($link) {
    $query = "SET @iris_model = (SELECT model_handle FROM ML_SCHEMA_admin.MODEL_CATALOG   ORDER BY model_id DESC LIMIT 1);";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $stmt->close();

    $query = "CALL sys.ML_MODEL_LOAD(@iris_model, NULL);";
    $stmt = $link->prepare($query);
    $stmt->execute(); 
    $stmt->close();
  }

  function use_model($link,$iris_model,$petal_l,$petal_w,$sepal_l,$sepal_w) {
    $query = "SET @row_input = JSON_OBJECT( 'sepal length', 
              $sepal_l, 'sepal width', $sepal_w, 'petal length', 
              $petal_l, 'petal width', $petal_w);";
    $stmt = $link->prepare($query);    
    $stmt->execute();
    $stmt->close();

    $query = "SELECT sys.ML_PREDICT_ROW(@row_input, @iris_model,NULL);";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $stmt->bind_result($pred_out);
    $stmt->fetch();
    $predict= $pred_out;
    $stmt->close();

    $query = "SELECT sys.ML_EXPLAIN_ROW(@row_input, @iris_model, JSON_OBJECT('prediction_explainer', 'permutation_importance'));";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $stmt->bind_result($explain);
    $stmt->fetch();
       $stmt->close();

    $query = "CALL sys.ML_SCORE('ml_data.iris_validate', 'class', @iris_model, 'balanced_accuracy', @score);";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $query = "SELECT @score as _p_out";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $stmt->bind_result($score);
    $stmt->fetch();
    $stmt->close();

    $query = "CALL sys.ML_MODEL_UNLOAD(@iris_model);";
    $stmt = $link->prepare($query);
    $stmt->execute();
    $stmt->close();
    show_output($predict,$explain,$score);
  }

function show_output($predict,$explain,$score) {

  $obj = json_decode($predict);
  echo '<pre>';
    echo "\n";
    echo "<h4>Based on the feature inputs that were provided, the model predicts that the Iris plant is of the class: </h4>";
      echo "<table>";
        echo "<tr>";
          echo "<td><b>";
            echo $obj->{'Prediction'} ;
          echo "</td>";
        echo "</tr>";
        echo "<tr>";
          echo "<td>";
          switch ($obj->{'Prediction'}) {
            case 'Iris-setosa':
                echo '<p><img class="img-responsive"src="images/iris_setosa.jpg" alt="iris_virginica"></p>'; 
                break;
            case 'Iris-versicolor':
                echo '<p><img class="img-responsive"src="images/iris_versicolor.jpg" alt="iris_virginica"></p>'; 
                break;
            case 'Iris-virginica':
                echo '<p><img class="img-responsive"src="images/iris_virginica.jpg" alt="iris_virginica"></p>'; 
              break;
          }
          echo "<td>";
            echo "<table>";
              echo "<tr>";
                echo'<td width="30px" style="width: 30px;"  align="left"><b>';
                  echo "Prediction:", $predict;
                echo "</td>";
              echo "</tr>";
              echo "<tr>";
                echo'<td width="30px" style="width: 30px;"  align="left"><b>';
                  echo "Explanation:", $explain;
                echo "</td>";
              echo "</tr>";
              echo "<tr>";
                echo'<td width="30px" style="width: 30px;"  align="left"><b>';
                  echo "Score:", $score;
                echo "</td>";
              echo "</tr>";
            echo "</table>";
          echo "</td>";
        echo "</tr>";
    echo "</table>";
   echo '</pre>';
}
?>

<!DOCTYPE HTML>  
  <html>
  <head>
  <style>
    .error {color: #FF0000;}
  </style>
  </head>
  <body>  
  <h3>Machine Learning "Hello World" - Task classification using the Iris Dataset </h3>
  <img class="img-responsive" src="images/iris-machinelearning.png" alt="iris_dataset" width="530" height="230"> 
  <h4>Example:</h4>
  <?php
  echo '<pre>';
  echo '<p><font color=blue>Iris-setosa->     </font>sepal length: 5.0   sepal width": 2.3   petal length: 3.3  petal width:1.0</p>';
  echo '<p><font color=blue>Iris-versicolor-> </font>sepal length: 4.9   sepal width": 3.1   petal length: 1.5  petal width:0.1</p>';
  echo '<p><font color=blue>Iris-virginica->  </font>sepal length: 6.4   sepal width": 2.8,  petal length: 5.6  petal width:2.2</p>';
  echo '</pre>';
  ?>
  <h3>Enter the following information:</h3>

  <p><span class="error">* required field</span></p>
  <form method="post" action="<?php $_SERVER["PHP_SELF"];?>"> 
    <span style="padding-left: 2px;"> Sepal Length: <span style="padding-left: 2px;"> <input type="number" min="0" max="10" step="0.1" name="sepal_l" value="<?php echo $sepal_l;?>" >
    <span class="error">* <?php echo $sepal_lErr;?></span>
    <br><br>
    <span style="padding-left: 2px;"> Sepal Width: <span style="padding-left: 8px;"> <input type="number" min="0" max="10" step="0.1" name="sepal_w" value="<?php echo $sepal_w;?>">
    <span class="error">* <?php echo $sepal_wErr;?></span>
    <br><br>
    <span style="padding-left: 2px;"> Petal Length: <span style="padding-left: 6px;"> <input type="number" min="0" max="10" step="0.1" name="petal_l" value="<?php echo $petal_l;?>">
    <span class="error">* <?php echo $petal_lErr;?></span>
    <br><br>
    <span style="padding-left: 2px;">Petal Width: <span style="padding-left: 10px;"> <input type="number" min="0" max="10" step="0.1" name="petal_w" value="<?php echo $petal_w;?>">
    <span class="error">* <?php echo $petal_wErr;?></span>
    <br><br>
    <input type="submit" name="submit" value="Submit">  
  </form>
  <?php

    if($petal_l !="" && $petal_w !="" && $sepal_l !="" && $sepal_w !=""){
      $iris_model = load_model($link); 
      use_model($link,$iris_model,$petal_l,$petal_w,$sepal_l,$sepal_w);
    }
  ?> 
</body>
</html>