package com.example.studentproject.controller;

import com.example.studentproject.entity.Student;
import com.example.studentproject.service.StudentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/students")
@CrossOrigin("*")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    // ✅ Create student
    @PostMapping
    public Student createStudent(@RequestBody Student student) {
        return studentService.create(student);
    }

    // ✅ Get all students
    @GetMapping
    public List<Student> getAllStudents() {
        return studentService.getAll();
    }

    // ✅ Assign course to student
    @PostMapping("/{studentId}/courses/{courseId}")
    public Student assignCourse(
            @PathVariable Long studentId,
            @PathVariable Long courseId
    ) {
        return studentService.assign(studentId, courseId);
    }
}