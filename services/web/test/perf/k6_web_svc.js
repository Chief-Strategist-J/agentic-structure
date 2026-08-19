import http from 'k6/http';
import { check } from 'k6';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<300'], // Next.js SSR p95 budget < 300ms
  },
};

export default function () {
  const res = http.get('http://localhost:3000');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
