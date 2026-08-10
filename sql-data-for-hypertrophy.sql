create schema hypertrophy_tracker;

-- 1. Create the Dimension Table for Exercises
CREATE TABLE Dim_Exercises (
    ExerciseID INT PRIMARY KEY,
    ExerciseName VARCHAR(100),
    MuscleGroup VARCHAR(50),
    MovementType VARCHAR(50)
);

-- 2. Create the Dimension Table for Workouts
CREATE TABLE Dim_Workouts (
    WorkoutID INT PRIMARY KEY,
    WorkoutDate DATE, 
    SessionType VARCHAR(50),
    DurationMinutes INT
);

-- 3. Create the Fact Table for Workout Sets
CREATE TABLE Fact_WorkoutSets (
    SetID INT PRIMARY KEY,
    WorkoutID INT,
    ExerciseID INT,
    WeightLifted DECIMAL(5,2),
    RepsCompleted INT,
    RPE INT,
    SetType VARCHAR(50),
    FOREIGN KEY (WorkoutID) REFERENCES Dim_Workouts(WorkoutID),
    FOREIGN KEY (ExerciseID) REFERENCES Dim_Exercises(ExerciseID)
);


-- Insert Exercise Catalog
INSERT INTO Dim_Exercises (ExerciseID, ExerciseName, MuscleGroup, MovementType)
VALUES 
    (1, 'Barbell Row', 'Back', 'Compound'),
    (2, 'Lat Pulldown', 'Back', 'Compound'),
    (3, 'Preacher Curl', 'Biceps', 'Isolation'),
    (4, 'Hammer Curl', 'Biceps', 'Isolation');

-- Insert Two Distinct Workout Sessions
INSERT INTO Dim_Workouts (WorkoutID, WorkoutDate, SessionType, DurationMinutes)
VALUES 
    (101, '2026-08-01', 'Pull Day (High Volume)', 65),
    (102, '2026-08-08', 'Pull Day (Low Volume)', 40);

-- Insert the Set-by-Set Data
INSERT INTO Fact_WorkoutSets (SetID, WorkoutID, ExerciseID, WeightLifted, RepsCompleted, RPE, SetType)
VALUES 
    -- Workout 101: High Volume (More sets, slightly lower intensity/RPE)
    (1, 101, 1, 60.00, 10, 7, 'Working Set'),
    (2, 101, 1, 60.00, 10, 8, 'Working Set'),
    (3, 101, 1, 60.00, 9,  9, 'Working Set'),
    (4, 101, 3, 25.00, 12, 7, 'Working Set'),
    (5, 101, 3, 25.00, 10, 8, 'Working Set'),
    (6, 101, 3, 25.00, 9,  9, 'Working Set'),

    -- Workout 102: Low Volume (Fewer sets, higher weight, max RPE)
    (7, 102, 1, 70.00, 8,  9, 'Working Set'),
    (8, 102, 1, 70.00, 7,  10, 'Working Set'),
    (9, 102, 3, 30.00, 8,  9, 'Working Set'),
    (10, 102, 3, 30.00, 6, 10, 'Working Set');
    
    
    SELECT 
    w.WorkoutDate,
    w.SessionType,
    e.MuscleGroup,
    COUNT(f.SetID) AS TotalSets,
    SUM(f.WeightLifted * f.RepsCompleted) AS TotalVolumeMoved
FROM 
    Fact_WorkoutSets f
INNER JOIN 
    Dim_Workouts w ON f.WorkoutID = w.WorkoutID
INNER JOIN 
    Dim_Exercises e ON f.ExerciseID = e.ExerciseID
WHERE 
    f.SetType = 'Working Set'
GROUP BY 
    w.WorkoutDate,
    w.SessionType,
    e.MuscleGroup
ORDER BY 
    w.WorkoutDate, 
    e.MuscleGroup;