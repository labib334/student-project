package com.example.studentproject.controller;

import com.example.studentproject.entity.Student;
import com.example.studentproject.service.StudentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/students")
@CrossOrigin("*")
public class StudentController {

    private final StudentService service;

    public StudentController(StudentService service) {
        this.service = service;
    }

    @GetMapping
    public List<Student> getAll() {
        return service.getAll();
    }

    @GetMapping("/my")
    public Student getByEmail(@RequestParam String email) {
        Student student = service.getByEmail(email);
        if (student == null) {
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.NOT_FOUND,
                    "Student not found"
            );
        }
        return student;
    }

    @GetMapping("/{id}")
    public Student getById(@PathVariable Long id) {
        return service.getById(id);
    }

    // 🔥 ADD STUDENT
    @PostMapping
    public Student create(@RequestBody Student student) {
        return service.create(student);
    }

    // 🔥 ASSIGN COURSE
    @PostMapping("/{sid}/courses/{cid}")
    public Student assign(@PathVariable Long sid, @PathVariable Long cid) {
        return service.assign(sid, cid);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}