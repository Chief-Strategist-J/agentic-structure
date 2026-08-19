import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% of requests must complete below 200ms
  },
};

export default function () {
  const res = http.get('http://localhost:8080/api/v1/entities');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
