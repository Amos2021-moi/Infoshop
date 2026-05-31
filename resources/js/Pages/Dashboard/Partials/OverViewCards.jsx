import * as React from "react"
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/Card" // 🌟 Changed from "card" to "Card" to fix Linux case sensitivity
import { ChartLine, Package, PackageCheck, User } from "lucide-react"
import { usePage } from "@inertiajs/react"
import { useCurrencyFormatter } from "@/lib/currencyFormatter"

export function OverViewCards() {
    const { data } = usePage().props;
    const auth = usePage().props.auth.user;
    const formatCurrency = useCurrencyFormatter();
    return (
        <>
            {(auth.user_role == "admin" || auth.user_role == "super-admin") && (
                <div className='grid gap-4 sm:grid-cols-2 lg:grid-cols-4 uppercase'>
                    <Card className="bg-blue-300 text-blue-950">
                        <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
                            <CardTitle className='text-sm font-medium'>
                                Total Items
                            </CardTitle>
                            <Package />
                        </CardHeader>
                        <CardContent>
                            <div className='text-2xl font-bold'>{data.totalItems}</div>
                            <p className='text-muted-foreground text-xs'>
                                {data.totalQuantities} QTY
                            </p>
                        </CardContent>
                    </Card>
                    <Card className="bg-yellow-200 text-yellow-900">
                        <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
                            <CardTitle className='text-sm font-medium'>
                                Total valuation
                            </CardTitle>
                            <ChartLine />
                        </CardHeader>
                        <CardContent>
                            <div className='text-2xl font-bold'>{formatCurrency(data.totalValuation)}</div>
                        </CardContent>
                    </Card>
                    <Card className="bg-green-300 text-green-950 cursor-pointer" onClick={() => window.location.href = route('sales.items.summary')}>
                        <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
                            <CardTitle className='text-sm font-medium'>Sold Items</CardTitle>
                            <PackageCheck />
                        </CardHeader>
                        <CardContent>
                            <div className='text-2xl font-bold'>{data.soldItems}</div>
                        </CardContent>
                    </Card>
                    <Card className="bg-red-300 text-red-950">
                        <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
                            <CardTitle className='text-sm font-medium'>
                                Customer balance
                            </CardTitle>
                            <User />
                        </CardHeader>
                        <CardContent>
                            <div className='text-2xl font-bold'>{formatCurrency(data.customerBalance)}</div>
                        </CardContent>
                    </Card>
                </div>
            )}
        </>
    )
}