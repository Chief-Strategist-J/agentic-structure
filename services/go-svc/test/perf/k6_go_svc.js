import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    service_load: {
      executor: 'constant-arrival-rate',
      rate: 100, // 100 RPS target
      timeUnit: '1s',
      duration: '30s',
      preAllocatedVUs: 20,
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<150'], // Service p95 budget < 150ms
  },
};

export default function () {
  const res = http.get('http://localhost:8080/health');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
