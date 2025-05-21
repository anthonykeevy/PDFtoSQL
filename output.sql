-- SCHEMA DEFINITIONS
-- CREATE TABLE ant.Model (
-- -- (Reference only, commented out)
  ModelID INT PRIMARY KEY,
  Brand NVARCHAR(50) NOT NULL,
  ModelName NVARCHAR(50) NOT NULL,
  EngineCapacity DECIMAL(3,1) NOT NULL,
  Variant NVARCHAR(20) NOT NULL,
  FuelType NVARCHAR(20) NOT NULL,
  VehicleDescription NVARCHAR(100) NOT NULL UNIQUE
);

-- CREATE TABLE ant.Part (
-- -- (Reference only, commented out)
  PartID INT PRIMARY KEY,
  PartNumber NVARCHAR(20) UNIQUE NOT NULL,
  Description NVARCHAR(500) NOT NULL,
  RRP DECIMAL(10,2),
  RRP_Fitted DECIMAL(10,2),
  FittingTime DECIMAL(4,2),
  Category NVARCHAR(150) NOT NULL
);

-- CREATE TABLE ant.ModelPart (
-- -- (Reference only, commented out)
  ModelID INT NOT NULL,
  PartID INT NOT NULL,
  Availability NVARCHAR(20) NOT NULL,
  PRIMARY KEY (ModelID, PartID),
  FOREIGN KEY (ModelID) REFERENCES ant.Model(ModelID),
  FOREIGN KEY (PartID) REFERENCES ant.Part(PartID)
);

-- AVAILABILITY MAPPING: STD→Standard, •→Yes, blank→No

-- MERGE ant.Model
MERGE ant.Model AS target
USING (VALUES
  (1,'Subaru','Liberty',2.5,'i','Petrol','MY20 Liberty 2.5 i'),
  (2,'Subaru','Liberty',3.0,'RS','Petrol','MY20 Liberty 3.0 RS'),
  (3,'Subaru','Outback',2.5,'i','Petrol','MY20 Outback 2.5 i'),
  (4,'Subaru','Outback',2.5,'X','Petrol','MY20 Outback 2.5 X'),
  (5,'Subaru','Outback',2.5,'P','Petrol','MY20 Outback 2.5 P'),
  (6,'Subaru','Outback',3.6,'R','Petrol','MY20 Outback 3.6 R'),
  (7,'Subaru','Outback',2.0,'D','Diesel','MY20 Outback 2.0 D'),
  (8,'Subaru','Outback',2.0,'D-P','Diesel','MY20 Outback 2.0 D-P'),
  (9,'Subaru','Levorg',1.6,'GT','Petrol','MY20 Levorg 1.6 GT'),
  (10,'Subaru','Levorg',1.6,'GT-P','Petrol','MY20 Levorg 1.6 GT-P'),
  (11,'Subaru','Levorg',2.0,'GT-S','Petrol','MY20 Levorg 2.0 GT-S'),
  (12,'Subaru','Levorg',2.0,'STI Sport','Petrol','MY20 Levorg 2.0 STI Sport'),
  (13,'Subaru','Forester',2.5,'i','Petrol','MY20 Forester 2.5 i'),
  (14,'Subaru','Forester',2.5,'i-L','Petrol','MY20 Forester 2.5 i-L'),
  (15,'Subaru','Forester',2.5,'i-P','Petrol','MY20 Forester 2.5 i-P'),
  (16,'Subaru','Forester',2.5,'i-S','Petrol','MY20 Forester 2.5 i-S'),
  (17,'Subaru','XV',2.0,'i','Petrol','MY20 XV 2.0 i'),
  (18,'Subaru','XV',2.0,'i-L','Petrol','MY20 XV 2.0 i-L'),
  (19,'Subaru','XV',2.0,'i-P','Petrol','MY20 XV 2.0 i-P'),
  (20,'Subaru','XV',2.0,'i-S','Petrol','MY20 XV 2.0 i-S'),
  (21,'Subaru','Impreza Hatch',2.0,'i','Petrol','MY20 Impreza Hatch 2.0 i'),
  (22,'Subaru','Impreza Hatch',2.0,'i-L','Petrol','MY20 Impreza Hatch 2.0 i-L'),
  (23,'Subaru','Impreza Hatch',2.0,'i-P','Petrol','MY20 Impreza Hatch 2.0 i-P'),
  (24,'Subaru','Impreza Hatch',2.0,'i-S','Petrol','MY20 Impreza Hatch 2.0 i-S'),
  (25,'Subaru','Impreza Sedan',2.0,'i','Petrol','MY20 Impreza Sedan 2.0 i'),
  (26,'Subaru','Impreza Sedan',2.0,'i-L','Petrol','MY20 Impreza Sedan 2.0 i-L'),
  (27,'Subaru','Impreza Sedan',2.0,'i-P','Petrol','MY20 Impreza Sedan 2.0 i-P'),
  (28,'Subaru','Impreza Sedan',2.0,'i-S','Petrol','MY20 Impreza Sedan 2.0 i-S'),
  (29,'Subaru','WRX',2.0,'R','Petrol','MY20 WRX 2.0 R'),
  (30,'Subaru','WRX',2.0,'RS','Petrol','MY20 WRX 2.0 RS'),
  (31,'Subaru','WRX STI',2.0,'STI','Petrol','MY20 WRX STI 2.0 STI'),
  (32,'Subaru','WRX STI',2.0,'STIS','Petrol','MY20 WRX STI 2.0 STIS'),
  (33,'Subaru','BRZ',2.0,'S','Petrol','MY20 BRZ 2.0 S'),
  (34,'Subaru','BRZ',2.0,'tS','Petrol','MY20 BRZ 2.0 tS')
) AS src(ModelID,Brand,ModelName,EngineCapacity,Variant,FuelType,VehicleDescription)
  ON target.VehicleDescription = src.VehicleDescription
WHEN MATCHED THEN UPDATE SET Brand=src.Brand,ModelName=src.ModelName,EngineCapacity=src.EngineCapacity,Variant=src.Variant,FuelType=src.FuelType
WHEN NOT MATCHED BY TARGET THEN INSERT (ModelID,Brand,ModelName,EngineCapacity,Variant,FuelType,VehicleDescription) VALUES (src.ModelID,src.Brand,src.ModelName,src.EngineCapacity,src.Variant,src.FuelType,src.VehicleDescription);

-- MERGE ant.Part
DECLARE @MaxPartID INT = ISNULL((SELECT MAX(PartID) FROM ant.Part), 0);
WITH NewParts AS (
  SELECT vp.PartNumber, vp.Description, vp.RRP, vp.RRP_Fitted, vp.FittingTime, vp.Category, ROW_NUMBER() OVER (ORDER BY vp.PartNumber) AS rn
  FROM (VALUES
  ) AS vp(PartNumber,Description,RRP,RRP_Fitted,FittingTime,Category)
), src AS (
  SELECT PartNumber,Description,RRP,RRP_Fitted,FittingTime,Category, rn+@MaxPartID AS PartID FROM NewParts
) MERGE ant.Part AS target USING src ON target.PartNumber=src.PartNumber
WHEN MATCHED THEN UPDATE SET Description=src.Description,RRP=src.RRP,RRP_Fitted=src.RRP_Fitted,FittingTime=src.FittingTime,Category=src.Category
WHEN NOT MATCHED BY TARGET THEN INSERT (PartID,PartNumber,Description,RRP,RRP_Fitted,FittingTime,Category) VALUES (src.PartID,src.PartNumber,src.Description,src.RRP,src.RRP_Fitted,src.FittingTime,src.Category);

-- MERGE ant.ModelPart
WITH SourceMap AS (SELECT * FROM (VALUES
  ) AS v(VehicleDescription,PartNumber,Availability)),
LookedUp AS (SELECT m.ModelID,p.PartID,sm.Availability FROM SourceMap sm JOIN ant.Model m ON m.VehicleDescription=sm.VehicleDescription JOIN ant.Part p ON p.PartNumber=sm.PartNumber)
MERGE ant.ModelPart AS target USING LookedUp AS src ON target.ModelID=src.ModelID AND target.PartID=src.PartID
WHEN MATCHED THEN UPDATE SET Availability=src.Availability
WHEN NOT MATCHED BY TARGET THEN INSERT (ModelID,PartID,Availability) VALUES (src.ModelID,src.PartID,src.Availability);