using { cuid, managed } from '@sap/cds/common';
namespace agi.learninghub;

entity Role : cuid, managed {
  title : String(120);
}

entity User : cuid, managed {
  name       : String(120);
  avatarUrl  : String(255);
  @assert.format: '^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$'
  @assert.notNull
  email      : String(255);
  role       : Association to Role;
}

entity Journey : cuid, managed {
  title              : String(120);
  description        : String(1111);
  isPublic           : Boolean;
  journeyProgresses  : Composition of many JourneyProgress on journeyProgresses.journey = $self;
  journeyCourses     : Composition of many JourneyCourse on journeyCourses.journey = $self;
}

entity JourneyCourse : cuid, managed {
  journey : Association to Journey;
  course  : Association to Course;
}

entity Course : cuid, managed {
  title            : String(120);
  description      : String(1111);
  isPublic         : Boolean;
  level            : Association to Level;
  courseCategories : Composition of many CourseCategory on courseCategories.course = $self;
  units            : Composition of many Unit on units.course = $self;
  courseProgresses : Composition of many CourseProgress on courseProgresses.course = $self;
  journeyCourses   : Composition of many JourneyCourse on journeyCourses.course = $self;
}

entity Unit : cuid, managed {
  title          : String(120);
  description    : String(1111);
  chapters       : Composition of many Chapter on chapters.unit = $self;
  unitProgresses : Composition of many UnitProgress on unitProgresses.unit = $self;
  course         : Association to Course;
}

entity Chapter : cuid, managed {
  title           : String(120);
  description     : String(1111);
  durationMinutes : Int16;
  htmlContent     : LargeString;
  unit            : Association to Unit;
}

entity Test : cuid, managed {
  title             : String(250);
  description       : String(1111);
  thresholdPercent  : Int16;
  timeLimitMinutes  : Int16;
  questions         : Composition of many Question on questions.test = $self;
  unit              : Association to Unit;
  course            : Association to Course;
}

entity Question : cuid, managed {
  title     : String(250);
  test      : Association to Test;
  answers   : Composition of many Answer on answers.question = $self;
}

entity Answer : cuid, managed {
  title     : String(250);
  question  : Association to Question;
  isCorrect : Boolean;
}

entity JourneyProgress : cuid, managed {
  journey   : Association to Journey;
  user      : Association to User;
  favorite  : Boolean;
  assigned  : Boolean;
  deadline  : Date;
}

entity CourseProgress : cuid, managed {
  course          : Association to Course;
  journeyProgress : Association to JourneyProgress;
  user            : Association to User;
  favorite        : Boolean;
  assigned        : Boolean;
  deadline        : Date;
}

entity UnitProgress : cuid, managed {
  courseProgress : Association to CourseProgress;
  unit           : Association to Unit;
}

entity ChapterProgress : cuid, managed {
  unitProgress : Association to UnitProgress;
  chapter      : Association to Chapter;
  isCompleted  : Boolean;
}

entity TestProgress : cuid, managed {
  unitProgress       : Association to UnitProgress;
  courseProgress     : Association to CourseProgress;
  questionProgresses : Composition of many QuestionProgress on questionProgresses.testProgress = $self;
  title              : String(250);
  description        : String(1111);
  thresholdPercent   : Int16;
  timeLimitMinutes   : Int16;
}

entity QuestionProgress : cuid, managed {
  testProgress     : Association to TestProgress;
  answerProgresses : Composition of many AnswerProgress on answerProgresses.questionProgress = $self;
  title            : String(250);
}

entity AnswerProgress : cuid, managed {
  questionProgress : Association to QuestionProgress;
  title            : String(250);
  isCorrect        : Boolean;
  isSelected       : Boolean;
}

entity Level : cuid, managed {
  title : String(120);
}

entity Category : cuid, managed {
  title            : String(120);
  courseCategories : Composition of many CourseCategory on courseCategories.category = $self;
}

entity CourseCategory : cuid {
  course   : Association to Course;
  category : Association to Category;
}
