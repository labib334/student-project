package com.example.studentproject.controller;

import com.example.studentproject.entity.Course;
import com.example.studentproject.service.CourseService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
}