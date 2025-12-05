const cds = require('@sap/cds');
const { SELECT, INSERT, UPDATE } = cds;

module.exports = (srv) => {

  const {
    JourneyProgresses,
    CourseProgresses,
    UnitProgresses,
    ChapterProgresses,
    TestProgresses,
    QuestionProgresses,
    AnswerProgresses,
    JourneyCourses,
    Units,
    Chapters,
    Tests,
    Questions,
    Answers
  } = cds.entities('agi.learninghub');

  function deny(req, message = 'ERROR.NOT_AUTHORIZED') {
    req.reject(403, req._t(message));
  }

  function getId(req) {
    if (req.data?.ID) return req.data.ID;
    if (req.params?.[0]?.ID) return req.params[0].ID;
    return null;
  }

  async function checkOwner(req, entity) {
    const id = getId(req);
    if (!id) return deny(req);

    const record = await SELECT.one.from(entity).where({ ID: id });
    if (!record) return deny(req, 'ERROR.NOT_FOUND');

    let owner = record.user_ID;

    if (!owner && record.courseProgress_ID) {
      const cp = await SELECT.one.from(CourseProgresses)
        .columns('user_ID')
        .where({ ID: record.courseProgress_ID });

      if (!cp) return deny(req);
      owner = cp.user_ID;
    }

    if (owner !== req.user.id) return deny(req);

    return record;
  }

  async function createJourneyProgress(journeyProgressId, journeyId, userId) {
    const journeyCourses = await SELECT.from(JourneyCourses).where({ journey_ID: journeyId });

    for (const item of journeyCourses) {
      const courseProgress = await INSERT.into(CourseProgresses).entries({
        course_ID: item.course_ID,
        journeyProgress_ID: journeyProgressId,
        user_ID: userId
      });

      await createCourseProgress(courseProgress.ID, item.course_ID);
    }
  }

  async function createCourseProgress(courseProgressId, courseId) {
    const units = await SELECT.from(Units).where({ course_ID: courseId });

    for (const unit of units) {
      const unitProgress = await INSERT.into(UnitProgresses).entries({
        unit_ID: unit.ID,
        courseProgress_ID: courseProgressId
      });

      await createChapterProgress(unitProgress.ID, unit.ID);
      await createTestProgress(unitProgress.ID, courseProgressId, unit.ID);
    }
  }

  async function createChapterProgress(unitProgressId, unitId) {
    const chapters = await SELECT.from(Chapters).where({ unit_ID: unitId });

    for (const chapter of chapters) {
      await INSERT.into(ChapterProgresses).entries({
        unitProgress_ID: unitProgressId,
        chapter_ID: chapter.ID,
        isCompleted: false
      });
    }
  }

  async function createTestProgress(unitProgressId, courseProgressId, unitId) {
    const tests = await SELECT.from(Tests).where({ unit_ID: unitId });

    for (const test of tests) {
      const testProgress = await INSERT.into(TestProgresses).entries({
        unitProgress_ID: unitProgressId,
        courseProgress_ID: courseProgressId,
        test_ID: test.ID,
        title: test.title,
        description: test.description,
        thresholdPercent: test.thresholdPercent,
        timeLimitMinutes: test.timeLimitMinutes
      });

      await copyQuestions(testProgress.ID, test.ID);
    }
  }

  async function copyQuestions(testProgressId, testId) {
    const questions = await SELECT.from(Questions).where({ test_ID: testId });

    for (const q of questions) {
      const qProgress = await INSERT.into(QuestionProgresses).entries({
        testProgress_ID: testProgressId,
        title: q.title
      });

      const answers = await SELECT.from(Answers).where({ question_ID: q.ID });

      const entries = answers.map(a => ({
        questionProgress_ID: qProgress.ID,
        title: a.title,
        isCorrect: a.isCorrect,
        isSelected: false
      }));

      await INSERT.into(AnswerProgresses).entries(entries);
    }
  }

  srv.after('CREATE', JourneyProgresses, async (data, req) => {
    await createJourneyProgress(data.ID, data.journey_ID, req.user.id);
  });

  srv.before('UPDATE', ChapterProgresses, async (req) => {
    if (!req.data.isCompleted) return;

    const chapterProgress = await checkOwner(req, ChapterProgresses);
    const chapter = await SELECT.one.from(Chapters).where({ ID: chapterProgress.chapter_ID });

    if (!chapter) return req.reject(404, req._t('CHAPTER.NOT_FOUND'));

    const previousChapters = await SELECT.from(Chapters)
      .where({ unit_ID: chapter.unit_ID })
      .and({ order: { '<': chapter.order } });

    if (previousChapters.length > 0) {
      const incompletePrevious = await SELECT.from(ChapterProgresses).where({
        unitProgress_ID: chapterProgress.unitProgress_ID,
        chapter_ID: { in: previousChapters.map(ch => ch.ID) },
        isCompleted: false
      });

      if (incompletePrevious.length > 0)
        return req.reject(409, req._t('CHAPTER.PREVIOUS_NOT_COMPLETED'));
    }
  });

  srv.on('submitTest', async (req) => {
    const { testProgress_ID } = req.data;
    if (!testProgress_ID) return req.reject(400, req._t('TEST.PROGRESS_REQUIRED'));

    const testProgress = await SELECT.one.from(TestProgresses).where({ ID: testProgress_ID });
    if (!testProgress) return req.reject(404, req._t('TEST.NOT_FOUND'));

    const cp = await SELECT.one.from(CourseProgresses)
      .where({ ID: testProgress.courseProgress_ID });

    if (!cp || cp.user_ID !== req.user.id) return deny(req);

    if (testProgress.passed != null)
      return req.reject(409, req._t('TEST.ALREADY_SUBMITTED'));

    const qProgress = await SELECT.from(QuestionProgresses).where({ testProgress_ID });
    const qIds = qProgress.map(q => q.ID);

    const answers = await SELECT.from(AnswerProgresses)
      .where({ questionProgress_ID: { in: qIds } });

    const map = {};
    for (const a of answers) {
      if (!map[a.questionProgress_ID]) map[a.questionProgress_ID] = [];
      map[a.questionProgress_ID].push(a);
    }

    let correct = 0;

    for (const q of qProgress) {
      const list = map[q.ID];
      const ok = list && list.every(a => a.isCorrect === a.isSelected);
      if (ok) correct++;
    }

    const total = qProgress.length;
    const score = total === 0 ? 0 : Math.round((correct / total) * 100);
    const passed = score >= testProgress.thresholdPercent;

    await UPDATE(TestProgresses)
      .set({ scorePercent: score, passed })
      .where({ ID: testProgress_ID });

    return {
      message: req._t('TEST.SUBMITTED'),
      scorePercent: score,
      passed
    };
  });
};
