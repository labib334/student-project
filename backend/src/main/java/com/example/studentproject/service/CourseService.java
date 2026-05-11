package com.example.studentproject.service;

import com.example.studentproject.entity.Course;
import com.example.studentproject.entity.Student;
import com.example.studentproject.repository.CourseRepository;
import com.example.studentproject.repository.StudentRepository;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class CourseService {

    private final CourseRepository repo;
    private final StudentRepository studentRepo;

    public CourseService(CourseRepository repo, StudentRepository studentRepo) {
        this.repo = repo;
        this.studentRepo = studentRepo;
    }

    public Course create(Course c) {
        return repo.save(c);
    }

    public List<Course> getAll() {
        return repo.findAll();
    }

    public void delete(Long id) {
        Course course = repo.findById(id).orElseThrow();

        if (course.getStudents() != null) {
            course.getStudents().clear();
        }

        repo.delete(course);
    }

    // 🔥 NEW: Get popular courses (sorted by enrollment count)
    public List<Map<String, Object>> getPopularCourses() {
        List<Course> allCourses = repo.findAll();
        
        return allCourses.stream()
            .map(course -> {
                Map<String, Object> map = new HashMap<>();
                map.put("courseId", course.getId());
                map.put("title", course.getTitle());
                map.put("description", course.getDescription());
                map.put("enrollmentCount", course.getStudents() != null ? course.getStudents().size() : 0);
                return map;
            })
            .sorted((a, b) -> Integer.compare((Integer)b.get("enrollmentCount"), (Integer)a.get("enrollmentCount")))
            .collect(Collectors.toList());
    }

    // 🔥 NEW: Get department-wise course enrollment statistics
    public List<Map<String, Object>> getDepartmentWiseStats() {
        List<Student> allStudents = studentRepo.findAll();
        
        // Group by department and count enrollments per course
        Map<String, Map<String, Integer>> deptStats = new HashMap<>();
        
        for (Student student : allStudents) {
            String dept = student.getDepartment() != null ? student.getDepartment() : "Unknown";
            
            if (student.getCourses() != null && !student.getCourses().isEmpty()) {
                for (Course course : student.getCourses()) {
                    String courseKey = course.getTitle();
                    
                    deptStats.computeIfAbsent(dept, k -> new HashMap<>())
                        .merge(courseKey, 1, Integer::sum);
                }
            }
        }
        
        // Convert to list format
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Map.Entry<String, Map<String, Integer>> entry : deptStats.entrySet()) {
            String department = entry.getKey();
            Map<String, Integer> courses = entry.getValue();
            
            Map<String, Object> deptMap = new HashMap<>();
            deptMap.put("department", department);
            deptMap.put("totalStudents", allStudents.stream()
                .filter(s -> department.equals(s.getDepartment() != null ? s.getDepartment() : "Unknown"))
                .count());
            deptMap.put("courses", courses);
            
            result.add(deptMap);
        }
        
        return result;
    }
}