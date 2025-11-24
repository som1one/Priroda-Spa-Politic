import { Card, Col, List, Row, Statistic, Tag } from 'antd';
import { Column, Pie } from '@ant-design/plots';
import dayjs from 'dayjs';
import { useEffect, useMemo, useState } from 'react';
import apiClient from '../api/client';

const statusLabels = {
  confirmed: 'Подтверждено',
  pending: 'В ожидании',
  completed: 'Завершено',
  cancelled: 'Отменено',
};

const DashboardPage = () => {
  const [summary, setSummary] = useState(null);
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        setLoading(true);
        const [summaryRes, bookingsRes] = await Promise.all([
          apiClient.get('/admin/dashboard/summary', { timeout: 10000 }),
          apiClient.get('/admin/dashboard/bookings', { 
            params: { limit: 6 },
            timeout: 10000,
          }),
        ]);
        setSummary(summaryRes.data);
        setBookings(bookingsRes.data?.items ?? []);
      } catch (error) {
        console.error('Failed to load dashboard data', error);
        // Устанавливаем пустые данные при ошибке
        setSummary(null);
        setBookings([]);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const statusData = useMemo(() => (
    summary?.status_breakdown?.map((item) => ({
      type: statusLabels[item.status] ?? item.status,
      value: item.count,
    })) ?? []
  ), [summary]);

  const statusTotal = statusData.reduce((acc, item) => acc + item.value, 0);

  const monthlyData = useMemo(() => (
    summary?.monthly_bookings?.map((item) => ({
      month: dayjs(item.month).format('MMM YY'),
      value: item.count,
    })) ?? []
  ), [summary]);

  const pieConfig = {
    data: statusData,
    angleField: 'value',
    colorField: 'type',
    innerRadius: 0.65,
    legend: {
      position: 'bottom',
      itemName: { style: { fontSize: 12 } },
    },
    label: {
      type: 'inner',
      offset: '-50%',
      content: '{value}',
      style: { fill: '#fff', fontSize: 12 },
    },
    statistic: {
      title: false,
      content: {
        style: { fontSize: 14, fontWeight: 600 },
        content: statusTotal ? `Всего\n${statusTotal}` : 'Нет данных',
      },
    },
    padding: [16, 16, 40, 16],
  };

  const columnConfig = {
    data: monthlyData,
    xField: 'month',
    yField: 'value',
    columnWidthRatio: 0.5,
    tooltip: { showMarkers: false },
    color: '#415B2F',
    label: {
      position: 'top',
      style: { fontSize: 12 },
    },
  };

  return (
    <div className="dashboard-page">
      <Row gutter={[24, 24]}>
        <Col xs={24} md={8}>
          <Card loading={loading}>
            <Statistic title="Всего записей" value={summary?.total_bookings ?? 0} />
          </Card>
        </Col>
        <Col xs={24} md={8}>
          <Card loading={loading}>
            <Statistic title="Подтверждено" value={summary?.confirmed_bookings ?? 0} />
          </Card>
        </Col>
        <Col xs={24} md={8}>
          <Card loading={loading}>
            <Statistic title="Клиенты" value={summary?.total_users ?? 0} />
          </Card>
        </Col>
      </Row>

      <Row gutter={[24, 24]} style={{ marginTop: 24 }}>
        <Col xs={24} md={12}>
          <Card title="Записи по месяцам" loading={loading}>
            {monthlyData.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#6A6F7A' }}>Недостаточно данных</div>
            ) : (
              <Column {...columnConfig} />
            )}
          </Card>
        </Col>
        <Col xs={24} md={12}>
          <Card title="Статусы записей" loading={loading}>
            {statusData.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#6A6F7A' }}>Недостаточно данных</div>
            ) : (
              <Pie {...pieConfig} />
            )}
          </Card>
        </Col>
      </Row>

      <Card title="Ближайшие записи" style={{ marginTop: 24 }} loading={loading}>
        <List
          dataSource={bookings}
          locale={{ emptyText: 'Нет записей' }}
          renderItem={(item) => (
            <List.Item
              actions={[
                <Tag color="green" key="status">
                  {statusLabels[item.status] ?? item.status}
                </Tag>,
              ]}
            >
              <List.Item.Meta
                title={item.service_name ?? 'Услуга'}
                description={`${item.client_name ?? 'Гость'} • ${dayjs(item.appointment_datetime).format('DD MMM HH:mm')}`}
              />
            </List.Item>
          )}
        />
      </Card>
    </div>
  );
};

export default DashboardPage;
