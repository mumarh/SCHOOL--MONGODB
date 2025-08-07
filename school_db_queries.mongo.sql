// ==========================================
// MongoDB Queries for School Management DB
// ==========================================


// --- FIND QUERIES ---

// 1. Find all students
db.students.find({});

// 2. Find all teachers who teach Science
db.teachers.find({ subject: "Science" });

// 3. Find students in class 10A
db.students.find({ class: "10A" });

// 4. Find a student by ID
db.students.findOne({ student_id: 2 });

// 5. Find courses taught by teacher with ID 1
db.courses.find({ teacher_id: 1 });

// 6. Find students older than 15
db.students.find({ age: { $gt: 15 } });

// 7. Find students who are either in 10A or 10B
db.students.find({ class: { $in: ["10A", "10B"] } });

// 8. Find all absent students on 2025-08-02
db.attendance.find({ date: "2025-08-02", status: "Absent" });

// 9. Find all enrollments for student_id 1
db.enrollments.find({ student_id: 1 });

// 10. Find grades where student scored an A
db.grades.find({ grade: "A" });



// --- PROJECTION & SORTING ---

// 11. Show only student names and age
db.students.find({}, { name: 1, age: 1, _id: 0 });

// 12. Sort students by age descending
db.students.find().sort({ age: -1 });

// 13. Sort teachers alphabetically
db.teachers.find().sort({ name: 1 });



// --- UPDATE QUERIES ---

// 14. Update student's class
db.students.updateOne({ student_id: 1 }, { $set: { class: "11A" } });

// 15. Increment age of student
db.students.updateOne({ student_id: 3 }, { $inc: { age: 1 } });

// 16. Mark attendance as Present for student 2 on a new date
db.attendance.insertOne({ student_id: 2, date: "2025-08-02", status: "Present" });

// 17. Replace entire student document (careful!)
db.students.replaceOne(
  { student_id: 2 },
  { student_id: 2, name: "Bobby", age: 16, gender: "M", class: "11B" }
);



// --- DELETE QUERIES ---

// 18. Delete one student
db.students.deleteOne({ student_id: 3 });

// 19. Delete all absences on a specific date
db.attendance.deleteMany({ date: "2025-08-02", status: "Absent" });

// 20. Delete teacher by name
db.teachers.deleteOne({ name: "Mr. Smith" });

// 21. Remove grades with grade 'F'
db.grades.deleteMany({ grade: "F" });



// --- AGGREGATIONS & ADVANCED ---

// 22. Count total number of students
db.students.countDocuments();

// 23. Count number of students per class
db.students.aggregate([
  { $group: { _id: "$class", total: { $sum: 1 } } }
]);

// 24. Average age of students
db.students.aggregate([
  { $group: { _id: null, avg_age: { $avg: "$age" } } }
]);

// 25. Get all student names and their grades using $lookup
db.students.aggregate([
  {
    $lookup: {
      from: "grades",
      localField: "student_id",
      foreignField: "student_id",
      as: "grades"
    }
  }
]);

// 26. Show students with their enrolled course names
db.students.aggregate([
  {
    $lookup: {
      from: "enrollments",
      localField: "student_id",
      foreignField: "student_id",
      as: "enrollments"
    }
  },
  { $unwind: "$enrollments" },
  {
    $lookup: {
      from: "courses",
      localField: "enrollments.course_id",
      foreignField: "course_id",
      as: "course_info"
    }
  },
  {
    $project: {
      name: 1,
      course: { $arrayElemAt: ["$course_info.name", 0] }
    }
  }
]);

// 27. Number of students enrolled in each course
db.enrollments.aggregate([
  { $group: { _id: "$course_id", count: { $sum: 1 } } }
]);

// 28. Attendance summary per student
db.attendance.aggregate([
  {
    $group: {
      _id: "$student_id",
      total_days: { $sum: 1 },
      present_days: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } }
    }
  }
]);

// 29. Find students who attended every day (basic check)
db.attendance.aggregate([
  { $match: { status: "Present" } },
  { $group: { _id: "$student_id", days_present: { $sum: 1 } } },
  { $match: { days_present: { $gte: 2 } } }
]);

// 30. Highest grade per student
db.grades.aggregate([
  {
    $group: {
      _id: "$student_id",
      top_grade: { $min: "$grade" }  // Lexical min (A < B < C)
    }
  }
]);

// 31. Group grades by grade
db.grades.aggregate([
  { $group: { _id: "$grade", count: { $sum: 1 } } }
]);

// 32. List all students and total enrolled courses
db.enrollments.aggregate([
  { $group: { _id: "$student_id", courses: { $sum: 1 } } }
]);

// 33. Count how many students are enrolled in "Algebra"
db.courses.aggregate([
  { $match: { name: "Algebra" } },
  {
    $lookup: {
      from: "enrollments",
      localField: "course_id",
      foreignField: "course_id",
      as: "student_enrollments"
    }
  },
  {
    $project: {
      name: 1,
      total_students: { $size: "$student_enrollments" }
    }
  }
]);

// 34. Rename field "class" to "section" in students
db.students.updateMany({}, { $rename: { "class": "section" } });

// 35. Add "email" field to all teachers
db.teachers.updateMany({}, { $set: { email: null } });

// 36. Set default subject if missing
db.teachers.updateMany(
  { subject: { $exists: false } },
  { $set: { subject: "General" } }
);

// 37. Find students without grades
db.students.find({
  student_id: {
    $nin: db.grades.distinct("student_id")
  }
});

// 38. Add timestamp to attendance
db.attendance.updateMany({}, { $currentDate: { timestamp: true } });

// 39. Students with grade A in any course
db.grades.aggregate([
  { $match: { grade: "A" } },
  {
    $lookup: {
      from: "students",
      localField: "student_id",
      foreignField: "student_id",
      as: "student_info"
    }
  },
  {
    $project: {
      student_name: { $arrayElemAt: ["$student_info.name", 0] },
      grade: 1
    }
  }
]);

// 40. Count of present/absent records
db.attendance.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } }
]);

// 41. Insert a new student
db.students.insertOne({ student_id: 4, name: "Diana", age: 14, gender: "F", section: "9A" });

// 42. Upsert a student (insert if not exists)
db.students.updateOne(
  { student_id: 5 },
  { $set: { name: "Evan", age: 15, gender: "M", section: "9B" } },
  { upsert: true }
);


// 43. Drop a collection
db.temp_data.drop();

// 44. Rename a collection (e.g., students -> pupils)
db.students.renameCollection("pupils");

// 45. Create a new index on student name
db.pupils.createIndex({ name: 1 });

// 46. Text search (if using text index)
db.pupils.createIndex({ name: "text" });
db.pupils.find({ $text: { $search: "Alice" } });

// 47. Find all courses with teacher info
db.courses.aggregate([
  {
    $lookup: {
      from: "teachers",
      localField: "teacher_id",
      foreignField: "teacher_id",
      as: "teacher"
    }
  }
]);

// 48. Add new course
db.courses.insertOne({ course_id: 103, name: "Chemistry", teacher_id: 2 });

// 49. Update course name
db.courses.updateOne({ course_id: 101 }, { $set: { name: "Advanced Algebra" } });

// 50. Remove all test data (careful!)

db.pupils.deleteMany({});
db.teachers.deleteMany({});
db.courses.deleteMany({});
db.enrollments.deleteMany({});
db.grades.deleteMany({});
db.attendance.deleteMany({});







// --- LOGICAL OPERATORS ---

// 51. Students in section "10A" AND age > 15
db.pupils.find({
  $and: [
    { section: "10A" },
    { age: { $gt: 15 } }
  ]
});

// 52. Students who are either in section "10B" OR are 14 years old
db.pupils.find({
  $or: [
    { section: "10B" },
    { age: 14 }
  ]
});

// 53. Students NOT in section "10A"
db.pupils.find({
  section: { $not: { $eq: "10A" } }
});

// 54. Students neither in section "10A" nor "10B"
db.pupils.find({
  section: { $nin: ["10A", "10B"] }
});



// --- RELATIONAL OPERATORS ---

// 55. Students older than 15
db.pupils.find({ age: { $gt: 15 } });

// 56. Students aged between 14 and 16
db.pupils.find({
  age: { $gte: 14, $lte: 16 }
});

// 57. Students whose age is NOT 15
db.pupils.find({
  age: { $ne: 15 }
});



// --- ARRAY OPERATORS

// 58. Students enrolled in course 101 or 102
db.enrollments.find({
  course_id: { $in: [101, 102] }
});

// 59. Students enrolled in both course 101 and 102 (hypothetical array)
db.students.find({
  courses: { $all: [101, 102] }
});

// 60. Find grade documents where multiple conditions apply in array
db.grades.find({
  $or: [
    { grade: "A" },
    { grade: "B" }
  ]
});



// --- ELEMENT OPERATORS ---

// 61. Find students with an email field (only teachers have email in our setup)
db.teachers.find({ email: { $exists: true } });

// 62. Find documents where a field is of type string
db.teachers.find({ name: { $type: "string" } });



// --- CURSOR METHODS ---

// 63. Show first 2 students
db.pupils.find().limit(2);


// 64. Skip the first 2 students and show the rest
db.pupils.find().skip(2);


// 65. Sort students by age descending
db.pupils.find().sort({ age: -1 });


// 66. Chain multiple cursor methods
db.pupils.find().sort({ age: -1 }).limit(2).pretty();


// 67. Grades with multiple nested objects (hypothetical example)
db.students.insertOne({
  student_id: 6,
  name: "Fiona",
  age: 16,
  section: "10C",
  grades: [
    { course_id: 101, grade: "A" },
    { course_id: 102, grade: "B" }
  ]
});


// 68. Find students who got A in course 101 (inside nested array)
db.pupils.find({
  grades: {
    $elemMatch: {
      course_id: 101,
      grade: "A"
    }
  }
});



// --- REGEX (text match) ---

// 69. Find students whose name starts with "A"
db.pupils.find({ name: /^A/ });

// 70. Find students whose name contains "li"
db.pupils.find({ name: /li/ });



// --- CONDITIONAL LOGIC ($cond, $ifNull) ---

// 71. Add a field "status" in projection based on age
db.pupils.aggregate([
  {
    $project: {
      name: 1,
      age: 1,
      status: {
        $cond: { if: { $gte: ["$age", 16] }, 
        then: "Senior", 
        else: "Junior" 
        }
      }
    }
  }
]);


// 72. Use $ifNull to handle missing email
db.teachers.aggregate([
  {
    $project: {
      name: 1,
      email: { $ifNull: ["$email", "No email assigned"] }
    }
  }
]);