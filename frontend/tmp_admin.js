const BASE_URL = "http://localhost:8080";

// ✅ LOGOUT FUNCTION
function logout() {
  localStorage.removeItem("email");
  window.location.href = "login.html";
}

function show(section) {
  ["dashboard","students","courses","assign"].forEach(id => {
    document.getElementById(id).classList.add("hidden");
  });
  document.getElementById(section).classList.remove("hidden");
  
  const titles = { 'dashboard': 'Overview', 'students': 'Student Management', 'courses': 'Course Catalog', 'assign': 'Course Enrollment' };
  document.getElementById('page-title').innerText = titles[section];
  
  document.querySelectorAll('.sidebar-link').forEach(btn => {
      btn.classList.remove('active');
      if(btn.innerText.toLowerCase().includes(section)) btn.classList.add('active');
  });
}

document.addEventListener('DOMContentLoaded', async () => {
  show('dashboard');
  await refreshAdminData();
  setupStudentEmailEvents();
});

let studentsCache = [];
let coursesCache = [];

async function refreshAdminData() {
  await Promise.all([
    loadStudents(),
    loadCourses(),
    populateStudentEmailList(),
    populateAssignmentDropdowns()
  ]);
}

function setupStudentEmailEvents() {
  const emailInput = document.getElementById("email");
  const emailSelect = document.getElementById("emailSelect");

  if (emailSelect) {
    emailSelect.addEventListener("change", event => {
      const selectedEmail = event.target.value;
      if (!selectedEmail) return;
      if (emailInput) emailInput.value = selectedEmail;
      fillStudentDetailsByEmail(selectedEmail);
    });
  }

  if (emailInput) {
    emailInput.addEventListener("change", event => {
      const selectedEmail = event.target.value.trim();
      if (selectedEmail) fillStudentDetailsByEmail(selectedEmail);
    });
  }
}

function fillStudentDetailsByEmail(email) {
  const found = studentsCache.find(s => s.email?.toLowerCase() === email.toLowerCase());
  const nameField = document.getElementById("name");
  const ageField = document.getElementById("age");
  const deptField = document.getElementById("dept");

  if (!found) {
    return;
  }

  if (nameField) nameField.value = found.name || found.username || "";
  if (ageField) ageField.value = found.age || "";
  if (deptField) deptField.value = found.department || "";
}

async function fetchStudents() {
  try {
    const res = await fetch(`${BASE_URL}/students`);
    if (!res.ok) throw new Error("Failed to load students");
    studentsCache = await res.json();
  } catch (err) {
    studentsCache = [];
    console.warn("Failed to fetch students", err);
  }
  return studentsCache;
}

async function fetchCourses() {
  try {
    const res = await fetch(`${BASE_URL}/courses`);
    if (!res.ok) throw new Error("Failed to load courses");
    coursesCache = await res.json();
  } catch (err) {
    coursesCache = [];
    console.warn("Failed to fetch courses", err);
  }
  return coursesCache;
}

async function addStudent() {
  const nameVal = document.getElementById("name").value.trim();
  const emailVal = document.getElementById("email").value.trim();
  const ageVal = document.getElementById("age").value;
  const deptVal = document.getElementById("dept").value.trim();
  if (!nameVal || !emailVal) { alert("❌ Name & Email required"); return; }
  const student = { name: nameVal, email: emailVal, age: parseInt(ageVal) || 0, department: deptVal };
  try {
    const res = await fetch(`${BASE_URL}/students`, { method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify(student) });
    const text = await res.text();
    if (!res.ok) throw new Error(text || "Failed to add student");
    alert("✅ Student Added Successfully");
    await refreshAdminData();
  } catch (err) { alert("❌ Error: " + err.message); }
}

async function deleteStudent() {
  const id = delStudentId.value;
  if(!id) return alert("Enter Student ID");
  try {
    const res = await fetch(`${BASE_URL}/students/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error("Delete failed");
    alert("✅ Student Deleted");
    await refreshAdminData();
  } catch (err) { alert("❌ " + err.message); }
}

async function addCourse() {
  try {
    const res = await fetch(`${BASE_URL}/courses`, { method: "POST", headers: {"Content-Type":"application/json"}, body: JSON.stringify({ title: title.value, description: desc.value }) });
    if (!res.ok) throw new Error("Failed");
    alert("✅ Course Added Successfully");
    await refreshAdminData();
  } catch (err) { alert("❌ " + err.message); }
}

async function deleteCourse() {
  const id = delCourseId.value;
  if(!id) return alert("Enter Course ID");
  try {
    const res = await fetch(`${BASE_URL}/courses/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error("Delete failed");
    alert("✅ Course Deleted");
    await refreshAdminData();
  } catch (err) { alert("❌ " + err.message); }
}

async function assign() {
  const mode = document.getElementById("searchMode").value;
  const courseId = document.getElementById("courseSelect").value;
  const studentId = mode === "id" ? document.getElementById("studentIdInput").value.trim() : document.getElementById("studentSelect").value;

  if (!studentId) return alert("Select a student or enter a student ID.");
  if (!courseId) return alert("Select a course.");

  const student = studentsCache.find(s => String(s.id) === String(studentId));
  if (!student) return alert("Student not found. Please refresh and try again.");

  if (student.courses && student.courses.some(c => String(c.id) === String(courseId))) {
    return alert("⚠️ This student is already enrolled in the selected course.");
  }

  try {
    const res = await fetch(`${BASE_URL}/students/${studentId}/courses/${courseId}`, { method: "POST" });
    const text = await res.text();
    if (!res.ok) throw new Error(text || "Invalid Student or Course ID");
    alert("✅ Enrollment Successful");
    await refreshAdminData();
    updateSelectedStudentEnrollments(studentId);
  } catch (err) { alert("❌ " + err.message); }
}

function onSearchModeChange() {
  const mode = document.getElementById("searchMode").value;
  const emailArea = document.getElementById("emailSearchArea");
  const idArea = document.getElementById("idSearchArea");
  const studentSelect = document.getElementById("studentSelect");
  const studentIdInput = document.getElementById("studentIdInput");

  if (mode === "id") {
    emailArea.classList.add("hidden");
    idArea.classList.remove("hidden");
    if (studentSelect) studentSelect.value = "";
  } else {
    idArea.classList.add("hidden");
    emailArea.classList.remove("hidden");
    if (studentIdInput) studentIdInput.value = "";
  }
  clearStudentEnrollments();
}

function onStudentSelectionChange() {
  const studentId = document.getElementById("studentSelect").value;
  if (!studentId) {
    clearStudentEnrollments();
    return;
  }
  updateSelectedStudentEnrollments(studentId);
}

function onStudentIdInput() {
  const studentId = document.getElementById("studentIdInput").value.trim();
  if (!studentId) {
    clearStudentEnrollments();
    return;
  }
  updateSelectedStudentEnrollments(studentId);
}

function clearStudentEnrollments() {
  const enrollments = document.getElementById("studentEnrollments");
  const currentCourses = document.getElementById("currentCourses");
  if (enrollments) enrollments.classList.add("hidden");
  if (currentCourses) currentCourses.innerHTML = "No student selected yet.";
}

function updateSelectedStudentEnrollments(identifier) {
  const student = studentsCache.find(s => String(s.id) === String(identifier));
  const enrollments = document.getElementById("studentEnrollments");
  const currentCourses = document.getElementById("currentCourses");

  if (!student) {
    if (enrollments) enrollments.classList.remove("hidden");
    if (currentCourses) currentCourses.innerHTML = `<span class="text-red-500">Student not found.</span>`;
    return;
  }

  if (enrollments) enrollments.classList.remove("hidden");

  if (!student.courses || student.courses.length === 0) {
    if (currentCourses) currentCourses.innerHTML = `<span class="text-gray-500">No courses enrolled yet.</span>`;
    return;
  }

  if (currentCourses) {
    currentCourses.innerHTML = student.courses.map(c => `<span class="inline-flex items-center gap-2 bg-purple-50 text-purple-700 px-3 py-1 rounded-full text-xs font-semibold">${c.title || 'Course'}<span class="text-gray-400">(${c.id})</span></span>`).join(" ");
  }
}

async function loadStudents() {
  const container = document.getElementById("courseStudents");
  container.innerHTML = `<div class="flex justify-center p-4"><i class="fas fa-spinner fa-spin text-indigo-500"></i></div>`;
  try {
    const data = await fetchCourses();
    container.innerHTML = "";
    data.forEach(c => {
      const students = c.students && c.students.length > 0 ? c.students.map(s => `<span class="bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded text-xs font-bold">${s.name || s.username}</span>`).join(" ") : "<span class='text-gray-400'>No students enrolled</span>";
      const li = document.createElement("li");
      li.className = "bg-gray-50 p-4 rounded-xl border border-gray-100 flex flex-col gap-2";
      li.innerHTML = `<div class="flex justify-between items-center"><span class="font-bold text-gray-700">${c.title}</span><span class="text-[10px] text-gray-400 font-mono">ID: ${c.id || 'N/A'}</span></div><div class="flex flex-wrap gap-1">${students}</div>`;
      container.appendChild(li);
    });
  } catch (e) { container.innerHTML = "Error loading courses"; }
}

async function populateStudentEmailList() {
  try {
    await fetchStudents();

    const emailSet = new Set();
    studentsCache.forEach(s => s.email && emailSet.add(s.email));

    try {
      const usersRes = await fetch(`${BASE_URL}/auth/emails`);
      const userEmails = usersRes.ok ? await usersRes.json() : [];
      userEmails.forEach(email => email && emailSet.add(email));
    } catch (err) {
      console.warn("Unable to load auth emails", err);
    }

    const dl = document.getElementById("studentEmails");
    const emailSelect = document.getElementById("emailSelect");
    if (dl) dl.innerHTML = "";
    if (emailSelect) {
      emailSelect.innerHTML = `<option value="">Search or choose an email</option>`;
    }

    emailSet.forEach(email => {
      if (dl) {
        const option = document.createElement("option");
        option.value = email;
        dl.appendChild(option);
      }
      if (emailSelect) {
        const option = document.createElement("option");
        option.value = email;
        option.text = email;
        emailSelect.appendChild(option);
      }
    });
  } catch (err) { console.warn("Unable to load student emails", err); }
}

async function populateAssignmentDropdowns() {
  await Promise.all([fetchStudents(), fetchCourses()]);

  const studentSelect = document.getElementById("studentSelect");
  const courseSelect = document.getElementById("courseSelect");

  if (studentSelect) {
    studentSelect.innerHTML = `<option value="">Choose a student email</option>`;
    studentsCache.forEach(s => {
      if (!s.email) return;
      const option = document.createElement("option");
      option.value = s.id || "";
      option.text = `${s.email} ${s.name ? `(${s.name})` : ""}`.trim();
      studentSelect.appendChild(option);
    });
  }

  if (courseSelect) {
    courseSelect.innerHTML = `<option value="">Choose a course</option>`;
    coursesCache.forEach(c => {
      const option = document.createElement("option");
      option.value = c.id || "";
      option.text = `${c.title || "Unnamed course"} ${c.id ? `(${c.id})` : ""}`.trim();
      courseSelect.appendChild(option);
    });
  }