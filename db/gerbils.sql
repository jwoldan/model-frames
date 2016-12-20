CREATE TABLE gerbils (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(255) NOT NULL,
  sound VARCHAR(255) NOT NULL
);

INSERT INTO
  gerbils (id, name, color, sound)
VALUES
  (1, "Buki", "Brown", "Squeak"),
  (2, "Coco", "Spotted", "Chichi");
