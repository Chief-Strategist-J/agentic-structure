import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    service_load: {
      executor: 'constant-arrival-rate',
      rate: 100,
      timeUnit: '1s',
      duration: '30s',
      preAllocatedVUs: 20,
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<150'],
  },
};

export default function () {
  const res = http.get('http://localhost:8081/health');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
