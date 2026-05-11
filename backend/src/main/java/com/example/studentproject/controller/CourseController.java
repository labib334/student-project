package com.example.studentproject.controller;

import com.example.studentproject.entity.Course;
import com.example.studentproject.service.CourseService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/courses")
@CrossOrigin("*")
public class CourseController {

    private final CourseService service;

    public CourseController(CourseService service) {
        this.service = service;
    }

    @PostMapping
    public Course create(@RequestBody Course c) {
        return service.create(c);
    }

    @GetMapping
    public List<Course> getAll() {
        return service.getAll();
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }

    // 🔥 NEW: Course Statistics Endpoints
    @GetMapping("/stats/popular")
    public List<Map<String, Object>> getPopularCourses() {
        return service.getPopularCourses();
    }

    @GetMapping("/stats/department")
    public List<Map<String, Object>> getDepartmentWiseStats() {
        return service.getDepartmentWiseStats();
    }
}