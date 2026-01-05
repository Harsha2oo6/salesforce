// List<Student__c> students = [SELECT Id, Name,Course__c,Age__c FROM Student__c];
// System.debug('Students: ' + students);
// for (Student__c student : students) {
//     System.debug('Student: ' + student.Name);
//     System.debug('Course: ' + student.Course__c);
//     System.debug('Age: ' + student.Age__c);
//     System.debug('--------------------------------');
// }

// Student__c student = new Student__c();
// student.Name = 'John Doe';
// student.Course__c = 'Math';
// student.Age__c = 20;
// insert student;
// System.debug('Student: ' + student.Name);
// System.debug('Course: ' + student.Course__c);
// System.debug('Age: ' + student.Age__c);
// System.debug('--------------------------------');

// Student__c student = [SELECT Id, Name,Course__c,Age__c FROM Student__c WHERE Name = 'John Doe' LIMIT 1];
// student.Course__c = 'Science';
// update student;
// System.debug('Student: ' + student.Name);
// System.debug('Course: ' + student.Course__c);
// System.debug('Age: ' + student.Age__c);
// System.debug('--------------------------------');

// Student__c studentToDelete = [SELECT Id, Name FROM Student__c WHERE Name = 'John Doe' LIMIT 1];
// delete studentToDelete;
// System.debug('Student deleted: ' + studentToDelete.Id + ' Student Name: ' + studentToDelete.Name);
// System.debug('--------------------------------');
// String branchName = 'CSE-ML';
// Student__c student = new Student__c();
// student.Name = 'test';
// student.Course__c = 'Salesforce';
// student.Age__c = 20;
// student.Branch__c = BranchServices.getBranchId(branchName);
// StudentController.createStudent(student);
// StudentController.updateStudentCourse('John Doe', 'Science');
// StudentController.deleteStudent('John Doe');



// string branch = 'CSE-DS';
// Id branchId = BranchServices.getBranchId(branch);
// List<Student__c> students = BranchServices.getStudentUnderBranch(branchId);
// System.debug('Branch ID: ' + branchId +' Branch Name: ' + branch + ' Students: ' + students.size());
// for (Student__c student : students) {
//     System.debug('Student ID: ' + student.Reg_No__c + ' Student Name: ' + student.Name);
//     System.debug('Student Course: ' + student.Course__c);
//     System.debug('Student Age: ' + student.Age__c);
//     System.debug('Student BranchId: ' + student.Branch__c);
//     System.debug('--------------------------------');
// }   

Map<string, List<Student__c>> studentsMap = BranchServices.getAllStudentsAndBranches();
System.debug('Students Map: ' + studentsMap.get('CSE-DS'));
// for (string branchName : studentsMap.keySet()) {
//     System.debug('Branch Name: ' + branchName);
//     for (Student__c student : studentsMap.get(branchName)) {
//         System.debug('Student ID: ' + student.Reg_No__c + ' Student Name: ' + student.Name);
//         System.debug('Student Course: ' + student.Course__c);
//         System.debug('Student Age: ' + student.Age__c);
//         System.debug('Student BranchId: ' + student.Branch__c);
//         System.debug('--------------------------------');
//     }
// }