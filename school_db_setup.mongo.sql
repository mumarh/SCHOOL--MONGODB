// ================================
// MongoDB School Management System
// ================================

// Switch to the 'school' database
use school;


// -----------------------------
// 1. Insert students
// -----------------------------
db.students.insertMany([
  { student_id: 1, name: "Alice", age: 15, gender: "F", class: "10A" },
  { student_id: 2, name: "Bob", age: 16, gender: "M", class: "10B" },
  { student_id: 3, name: "Charlie", age: 15, gender: "M", class: "10A" }
]);


// -----------------------------
// 2. Insert teachers
// -----------------------------
db.teachers.insertMany([
  { teacher_id: 1, name: "Mr. Smith", subject: "Math" },
  { teacher_id: 2, name: "Ms. Johnson", subject: "Science" }
]);


// -----------------------------
// 3. Insert courses
// -----------------------------
db.courses.insertMany([
  { course_id: 101, name: "Algebra", teacher_id: 1 },
  { course_id: 102, name: "Biology", teacher_id: 2 }
]);


// -----------------------------
// 4. Insert enrollments
// -----------------------------
db.enrollments.insertMany([
  { student_id: 1, course_id: 101 },
  { student_id: 1, course_id: 102 },
  { student_id: 2, course_id: 101 }
]);


// -----------------------------
// 5. Insert grades
// -----------------------------
db.grades.insertMany([
  { student_id: 1, course_id: 101, grade: "A" },
  { student_id: 1, course_id: 102, grade: "B" },
  { student_id: 2, course_id: 101, grade: "C" }
]);


// -----------------------------
// 6. Insert attendance records
// -----------------------------
db.attendance.insertMany([
  { student_id: 1, date: "2025-08-01", status: "Present" },
  { student_id: 1, date: "2025-08-02", status: "Absent" },
  { student_id: 2, date: "2025-08-01", status: "Present" }
]);
