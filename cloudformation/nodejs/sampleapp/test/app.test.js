const test = require(`ava`);
const request = require('supertest');

import app from '../app';

// test status page
test('status:Success', async t => {
    t.plan(2);

    const res = await request(app)
        .get('/status');

    t.is(res.status, 200);
    t.is(res.text, '{"status":"ok"}');
});

// test root page
test('status:Home', async t => {
    t.plan(2);

    const res = await request(app)
        .get('/');

    t.is(res.status, 200);
    t.is(res.text, 'hello');
});