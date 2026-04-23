
"use client"

import * as React from "react"
import {
    SquareTerminal,
    Package,
    ShoppingCart,
    Users,
    LucideIcon,
    Truck,
    LayoutDashboard,
    FileText,
    LogOut
} from "lucide-react"

import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
    SidebarRail,
} from "@/components/ui/sidebar"
import { authClient } from "@/lib/auth-client"
import { useRouter, usePathname } from "next/navigation"

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
    const router = useRouter();
    const pathname = usePathname();
    const session = authClient.useSession();

    const handleSignOut = async () => {
        await authClient.signOut({
            fetchOptions: {
                onSuccess: () => {
                    router.push("/login"); // redirect to login page
                },
            },
        });
    };

    const [mounted, setMounted] = React.useState(false);

    React.useEffect(() => {
        setMounted(true);
    }, []);

    const menuItems = [ // ... menu items ...
        {
            title: "Dashboard",
            url: "/admin",
            icon: LayoutDashboard,
        },
        {
            title: "Orders",
            url: "/admin/orders",
            icon: ShoppingCart,
        },
        {
            title: "Inventory",
            url: "/admin/inventory",
            icon: Package,
        },
        {
            title: "Stock Ledger",
            url: "/admin/stock-ledger",
            icon: FileText,
        },
        {
            title: "Suppliers",
            url: "/admin/suppliers",
            icon: Truck,
        },
        {
            title: "Shops",
            url: "/admin/shops",
            icon: SquareTerminal,
        },
        {
            title: "Salesmen",
            url: "/admin/salesmen",
            icon: Users,
        },
    ];

    return (
        <Sidebar collapsible="icon" {...props} className="border-r border-gray-200 dark:border-gray-800">
            <SidebarHeader>
                <div className="flex items-center p-2 font-bold text-xl">
                    <SquareTerminal className="mr-2 h-6 w-6" />
                    <span className="group-data-[collapsible=icon]:hidden">Agency System</span>
                </div>
            </SidebarHeader>
            <SidebarContent>
                <SidebarMenu className="gap-2 p-2">
                    {menuItems.map((item) => (
                        <SidebarMenuItem key={item.title}>
                            <SidebarMenuButton
                                asChild
                                isActive={pathname === item.url || pathname.startsWith(item.url + "/")}
                                tooltip={item.title}
                            >
                                <a href={item.url}>
                                    <item.icon />
                                    <span>{item.title}</span>
                                </a>
                            </SidebarMenuButton>
                        </SidebarMenuItem>
                    ))}
                </SidebarMenu>
            </SidebarContent>
            <SidebarFooter>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <div className="flex items-center p-2 gap-2 text-sm text-muted-foreground group-data-[collapsible=icon]:hidden">
                            <div className="flex flex-col">
                                <span className="font-medium text-foreground">{mounted && session.data?.user?.name ? session.data.user.name : "User"}</span>
                                <span className="text-xs">{mounted && session.data?.user?.email ? session.data.user.email : ""}</span>
                            </div>
                        </div>
                        <SidebarMenuButton onClick={handleSignOut} tooltip="Sign Out" className="text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-950/20">
                            <LogOut className="ml-auto" />
                            <span>Sign Out</span>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarFooter>
            <SidebarRail />
        </Sidebar>
    )
}
