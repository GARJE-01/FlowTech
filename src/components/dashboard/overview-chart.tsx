"use client"

import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts"

interface OverviewChartProps {
    data: { name: string; total: number }[];
}

export function OverviewChart({ data }: OverviewChartProps) {
    return (
        <ResponsiveContainer width="100%" height={350}>
            <BarChart data={data}>
                <XAxis
                    dataKey="name"
                    stroke="#888888"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                />
                <YAxis
                    stroke="#888888"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                    tickFormatter={(value) => `₹${value}`}
                />
                <Tooltip 
                    cursor={{fill: 'transparent'}}
                    formatter={(value: any) => [`₹${value}`, 'Revenue']}
                    contentStyle={{ 
                        borderRadius: "8px", 
                        border: "1px solid hsl(var(--border))", 
                        backgroundColor: "hsl(var(--background))", 
                        color: "hsl(var(--foreground))" 
                    }}
                    itemStyle={{ color: "hsl(var(--foreground))" }}
                />
                <Bar
                    dataKey="total"
                    fill="currentColor"
                    radius={[4, 4, 0, 0]}
                    className="fill-primary"
                />
            </BarChart>
        </ResponsiveContainer>
    )
}
