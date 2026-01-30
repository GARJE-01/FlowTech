
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Upload, FileUp } from "lucide-react"
import Papa from "papaparse"
import { importSuppliersFromCSV } from "@/actions/suppliers"

export function SupplierCSVImport() {
    const [loading, setLoading] = useState(false);

    const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        // Validation: Ensure it's a CSV
        if (file.name.endsWith('.xlsx') || file.name.endsWith('.xls') || (file.type && !file.type.includes('csv') && !file.type.includes('text'))) {
            alert("It looks like you uploaded an Excel file (.xlsx/.xls). Please 'Save As' -> 'CSV (Comma delimited)' in Excel and try again.");
            // Reset input
            e.target.value = '';
            return;
        }

        setLoading(true);
        Papa.parse(file, {
            header: true,
            complete: async (results) => {
                const res = await importSuppliersFromCSV(results.data);
                if (!res.success) {
                    alert("Import failed: " + res.error);
                } else {
                    alert(`Successfully imported ${res.count} suppliers.`);
                }
                setLoading(false);
            },
            error: (err) => {
                alert("CSV Parse Error: " + err.message);
                setLoading(false);
            }
        });
    };

    return (
        <div className="relative">
            <input
                type="file"
                accept=".csv"
                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                onChange={handleFileUpload}
                disabled={loading}
            />
            <Button variant="outline" disabled={loading}>
                {loading ? <Upload className="mr-2 h-4 w-4 animate-spin" /> : <FileUp className="mr-2 h-4 w-4" />}
                {loading ? "Importing..." : "Import CSV"}
            </Button>
        </div>
    )
}
